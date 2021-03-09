var rpc = require("discord-rpc")
const client = new rpc.Client({ transport: 'ipc' })
client.on('ready', () => {
client.request('SET_ACTIVITY', {
pid: process.pid,
activity : {
details : "Playing 𝗔𝘀𝗶𝗮𝗻𝗫 𝗨𝗻𝗶𝘁𝗲𝗱 𝗥𝗼𝗹𝗲𝗽𝗹𝗮𝘆 𝗦𝗲𝗿𝘃𝗲𝗿 18+ ɪɴᴅɪᴀɴ ᴡʜɪᴛᴇʟɪꜱᴛᴇᴅ",
assets : {
large_image : "lucifer_logo",
large_text : "Playing 𝗔𝘀𝗶𝗮𝗻𝗫 𝗨𝗻𝗶𝘁𝗲𝗱 𝗥𝗼𝗹𝗲𝗽𝗹𝗮𝘆 𝗦𝗲𝗿𝘃𝗲𝗿 18+ ɪɴᴅɪᴀɴ ᴡʜɪᴛᴇʟɪꜱᴛᴇᴅ" // THIS WILL SHOW AS "Playing <Status>" from the outisde
},
buttons : [{label : "JOIN AURP" , url : "https://discord.gg/SRGJ7y5aUa"}]
}
})
})
client.login({ clientId : "818901839222800404" }).catch(console.error);