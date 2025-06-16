import numpy as np
import ccxt
from ta.momentum import RSIIndicator
from ta.trend import EMAIndicator

exchange = ccxt.bybit({'enableRateLimit': True})

def fetch_ohlcv(symbol: str, timeframe: str = '1h', limit: int = 200):
    bars = exchange.fetch_ohlcv(symbol, timeframe=timeframe, limit=limit)
    return np.array(bars)

def calc_indicators(ohlcv: np.ndarray):
    close = ohlcv[:, 4]
    volume = ohlcv[:, 5]
    rsi = RSIIndicator(close).rsi()[-1]
    ema50 = EMAIndicator(close, window=50).ema_indicator()[-1]
    ema200 = EMAIndicator(close, window=200).ema_indicator()[-1]
    return rsi, ema50, ema200, volume.mean()

def detect_signal(symbol: str, tf: str = '1h'):
    ohlcv = fetch_ohlcv(symbol, tf)
    rsi, ema50, ema200, avg_vol = calc_indicators(ohlcv)
    last_price = ohlcv[-1, 4]
    last_vol = ohlcv[-1, 5]

    if rsi < 30 and ema50 > ema200 and last_vol > avg_vol:
        entry = round(last_price * 0.997, 2)
        sl = round(entry * 0.99, 2)
        tps = [round(entry * x, 2) for x in (1.012, 1.035, 1.08)]
        return 'LONG', entry, sl, tps, rsi, ema50, ema200, last_vol, avg_vol

    if rsi > 70 and ema50 < ema200 and last_vol > avg_vol:
        entry = round(last_price * 1.003, 2)
        sl = round(entry * 1.01, 2)
        tps = [round(entry * x, 2) for x in (0.988, 0.965, 0.92)]
        return 'SHORT', entry, sl, tps, rsi, ema50, ema200, last_vol, avg_vol

    return None
