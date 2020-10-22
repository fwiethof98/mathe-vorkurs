import os
import glob

import discord
from discord.message import Attachment

TOKEN = os.environ['DISCORD_TOKEN']
GUILD = os.environ['DISCORD_GUILD']

client = discord.Client()

@client.event
async def on_ready():
    print(f'{client.user.name} has connected to Discord!')
    guild = discord.utils.get(client.guilds, name=GUILD)
    channel = discord.utils.get(guild.text_channels, name="korrekturen")
    pdf_file = glob.glob("*.pdf").pop(0)
    with open(pdf_file, 'rb') as fp:
        await channel.send(file=discord.File(fp, glob.glob(pdf_file).pop(0)))
    await client.close()

client.run(TOKEN)
