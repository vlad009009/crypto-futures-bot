import os
import asyncio
from aiogram import Bot
from signals import detect_signal

API_TOKEN = os.getenv('8086833488:AAEQu0UA1bTDhXmxc9zAgfVqw7VmTmh9zSM')
TARGET_ID = os.getenv('5919952205')
SYMBOLS = ['BTCUSDT', 'ETHUSDT', 'LINKUSDT']
TIMEFRAMES = ['1h', '4h']

bot = Bot(token=API_TOKEN)

async def scheduler():
    while True:
        for sym in SYMBOLS:
            for tf in TIMEFRAMES:
                res = detect_signal(sym, tf)
                if res:
                    typ, entry, sl, tps, *_ = res
                    text = f"🟢 **{typ} сигнал — {sym} ({tf})**\n📍 Вход: {entry} / 🛑 SL: {sl} / 🎯 TP: {' / '.join(map(str, tps))}"
                    await bot.send_message(TARGET_ID, text, parse_mode="Markdown")
        await asyncio.sleep(900)  # Проверка каждые 15 минут

if __name__ == "__main__":
    asyncio.run(scheduler())
