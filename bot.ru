import os
from aiogram import Bot, Dispatcher, types
from signals import detect_signal

API_TOKEN = os.getenv('TELEGRAM_API_TOKEN')
TARGET_ID = os.getenv('TELEGRAM_TARGET_ID')

bot = Bot(token=API_TOKEN)
dp = Dispatcher(bot)

@dp.message_handler(commands=['start'])
async def cmd_start(m: types.Message):
    await m.reply(
        "Привет! Используй команду:\n"
        "`/signal SYMBOL TIMEFRAME`\n"
        "Пример: `/signal BTCUSDT 1h`"
    )

@dp.message_handler(commands=['signal'])
async def cmd_signal(m: types.Message):
    parts = m.text.split()
    if len(parts) != 3:
        return await m.reply("Неверный формат. Используй: `/signal BTCUSDT 1h`", parse_mode="Markdown")
    _, sym, tf = parts
    sym = sym.upper()
    res = detect_signal(sym, tf)
    if not res:
        return await m.reply("Сигналы не найдены.")
    typ, entry, sl, tps, rsi, ema50, ema200, vol, avg = res
    text = (
        f"🟢 **{typ} сигнал — {sym} ({tf})**\n"
        f"📍 Вход: {entry} / 🛑 SL: {sl} / 🎯 TP: {tps[0]} / {tps[1]} / {tps[2]}\n\n"
        f"📊 _RSI: {rsi:.1f} | EMA50: {ema50:.2f} | EMA200: {ema200:.2f}_\n"
        f"• Объём: {vol:.0f} (ср: {avg:.0f})\n\n"
        f"✅ Рекомендации: плечо до x5, размер позиции 2–3%, вход только по подтверждению свечного закрытия."
    )
    await bot.send_message(m.chat.id, text, parse_mode="Markdown")

if __name__ == '__main__':
    from aiogram import executor
    executor.start_polling(dp)
