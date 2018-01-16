URL = require "socket.url"
http = require "socket.http"
https = require "ssl.https"
ltn12 = require "ltn12"
serpent = (loadfile "./libs/serpent.lua")()
json = (loadfile "./libs/JSON.lua")()
mimetype = (loadfile "./libs/mimetype.lua")()
redis = (loadfile "./libs/redis.lua")()
JSON = (loadfile "./libs/dkjson.lua")()
tdcli = dofile("tdcli.lua")
http.TIMEOUT = 10
-------------------------------------------------------
Mehdi = 411026177     --در این قسمت ایدی عددی ربات را وارد کنید
-------------------------------------------------------
bot_id = 411026177     --در این قسمت ایدی عددی ربات را وارد کنید
-------------------------------------------------------
sudo_users = {439620509}    -- در ای قسمت ایدی مدیر اصلی
-------------------------------------------------------
function vardump(value)
print(serpent.block(value, {comment=false}))
end
-------------------------------------------------------
function is_ultrasudo(msg)
local var = false
for v,user in pairs(sudo_users) do
if user == msg.sender_user_id_ then
var = true
end
end
return var
end
-------------------------------------------------------
function is_sudo(msg) 
local hash = redis:sismember(Mehdi..'sudo:',msg.sender_user_id_)
if hash or is_ultrasudo(msg)  then
return true
else
return false
end
end
-------------------------------------------------------
function sleep(n) 
os.execute("sleep " .. tonumber(n)) 
end
-------------------------------------------------------
function tdcli_update_callback(data)
if (data.ID == "UpdateNewMessage") then
local msg = data.message_
local chat_id = tostring(msg.chat_id_)
local user_id = msg.sender_user_id_
local reply_id = msg.reply_to_message_id_
local txt = msg.content_.text_
local caption = msg.content_.caption_
if msg.date_ < (os.time() - 10) then
print("~~~~ Old Message ~~~~~")
return false
end
-------------------------------------------------------
local id = tostring(chat_id)
if id:match("-100") then
grouptype = "supergroup"
if not redis:sismember(Mehdi.."sgps:", chat_id) then
redis:sadd(Mehdi.."sgps:",chat_id)
end
elseif id:match("-") then
grouptype = "group"
if not redis:sismember(Mehdi.."gps:", chat_id) then
redis:sadd(Mehdi.."gps:",chat_id)
end
elseif id:match("") then
grouptype = "pv"
if not redis:sismember(Mehdi.."pv:", chat_id) then
redis:sadd(Mehdi.."pv:",chat_id)
end
end
redis:incr(Mehdi.."allmsg:")
-------------------------------------------------------
if msg.content_.ID == "MessageText" then
if redis:get(Mehdi.."autojoin") then
if txt:match("https://telegram.me/joinchat/%S+") or  txt:match("https://t.me/joinchat/%S+") then
local link = txt:match("https://telegram.me/joinchat/%S+") or  txt:match("https://t.me/joinchat/%S+")  
if link:match("t.me") then
link = string.gsub(link, "t.me", "telegram.me")
end
tdcli.importChatInviteLink(link, dl_cb, nil)
end
end
end
-------------------------------------------------------
if msg.content_.text_ then
-------------------------------------------------------
if txt:match("^[Ss]ave$") and reply_id and is_sudo(msg) then
function save(extra, result, success)
vardump(result)
if result.content_.ID == 'MessageContact' then
tdcli.importContacts(result.content_.contact_.phone_number_,result.content_.contact_.first_name_, (result.content_.contact_.last_name_ or ':D'), 0)
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '» کاربر [ '..result.content_.contact_.first_name_..' ] | [ '.. result.content_.contact_.phone_number_..' ] با موفقیت ذخیره شد.', 1, 'html')
end
end
tdcli.getMessage(chat_id,msg.reply_to_message_id_,save,nil)
end
if txt:match("^[Ss]etsudo$") and reply_id and is_ultrasudo(msg) then
function setsudo(extra, result, success)
if redis:sismember(Mehdi.."sudo:", result.sender_user_id_) then
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '» کاربر ( '..result.sender_user_id_..' ) مدیره.', 1, 'md')
else
redis:sadd(Mehdi.."sudo:", result.sender_user_id_)
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '» کاربر ( '..result.sender_user_id_..' ) مدیر شد.', 1, 'md')
end
end
tdcli.getMessage(chat_id,msg.reply_to_message_id_,setsudo,nil)
end
-------------------------------------------------------
if txt:match("^[Rr]emsudo$") and reply_id and is_ultrasudo(msg) then
function remenemy_reply(extra, result, success)
if not redis:sismember(Mehdi.."sudo:", result.sender_user_id_) then
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '» کاربر ( '..result.sender_user_id_..' ) مدیر نیست.', 1, 'md')
else
redis:srem(Mehdi.."sudo:", result.sender_user_id_)
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '» کاربر ( '..result.sender_user_id_..' ) سیک شد.', 1, 'md')
end
end
tdcli.getMessage(chat_id,msg.reply_to_message_id_,remenemy_reply,nil)
end
-------------------------------------------------------
if txt:match("^[Aa]ddtoall$") and msg.reply_to_message_id_ ~= 0 and is_sudo(msg) then
function add_reply(extra, result, success)
local gp = redis:smembers(Mehdi.."sgps:") or 0
local gps = redis:scard(Mehdi.."sgps:") + redis:scard(Mehdi..'gps:')
for i=1, #gp do
sleep(0.5)
tdcli.addChatMember(gp[i], result.sender_user_id_, 5)
end
local gp = redis:smembers(Mehdi.."gps:") or 0
for i=1, #gp do
sleep(0.5)
tdcli.addChatMember(gp[i], result.sender_user_id_, 5)
end
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '> This User Added To '..gps..' Sgps/Gps :D', 1, 'md')
end
tdcli.getMessage(chat_id,msg.reply_to_message_id_,add_reply,nil)
end
-------------------------------------------------------
if txt:match("^[Ss]tats$") and is_sudo(msg) then
meti = redis:scard(Mehdi.."sgps:")
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'امار سوپرگروه ها :  '..meti..':)', 1, 'html')
end
-------------------------------------------------------
if txt:match("^[Ll]eave all$") and is_sudo(msg) then
local kir = redis:smembers(Mehdi.."sgps:")
for R = 1, #kir do
tdcli.changeChatMemberStatus(kir[R], bot_id, 'Left')
end
local Kos = redis:smembers(Mehdi.."gps:")
for M = 1, #Kos do
tdcli.changeChatMemberStatus(Kos[M], bot_id, 'Left')
end
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'ربات با موفقیت از گروه ها خارج شد', 1, 'html')
redis:del(Mehdi.."sgps:")
end
-------------------------------------------------------
if txt:match("^[Rr]eset stats$") and is_sudo(msg) then
redis:del(Mehdi.."sgps:")
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'ریستش کردم داوش', 1, 'html')
end
-------------------------------------------------------
if txt:match("^[Pp]ing$") and is_sudo(msg) then
tdcli.forwardMessages(msg.chat_id_, chat_id,{[0] = msg.id_}, 0)
end
-------------------------------------------------------
if txt:match("^[Ss]hare$") and is_sudo(msg) then
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendContact(msg.chat_id_, msg.id_, 0, 1, nil, 923130503031, 'کله', 'کیری', bot_id)       -- در این قسمت شماره ربات بدون فاصله و سپس نام اول و سپس نام دوم
tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
-------------------------------------------------------
if txt:match("^[Aa]utojoin on$") and is_sudo(msg) then
if not redis:get(Mehdi.."autojoin") then
redis:set(Mehdi.."autojoin", true)
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'Auto Join Has Been Enable', 1, 'md')
else
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'Auto Join Is Already Enable', 1, 'md')
end
end
-------------------------------------------------------
if txt:match("^[Aa]utojoin off$") and is_sudo(msg) then
if redis:get(Mehdi.."autojoin") then
redis:del(Mehdi.."autojoin", true)
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'Auto Join Has Been Disable', 1, 'md')
else
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'Auto Join Is Already Disable', 1, 'md')
end
end
-------------------------------------------------------
if txt:match("^[Mm]arkread on$") and is_sudo(msg) then
if not redis:get(Mehdi.."markread:") then
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*MarkRead Has Been On ...!*', 1, 'md')
redis:set(Mehdi.."markread:", true)
else
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*MarkRead Is Already On ...!*', 1, 'md')
end
end
-------------------------------------------------------
if txt:match("^[Mm]arkread off$") and is_sudo(msg) then
if redis:get(Mehdi.."markread:") then
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*MarkRead Has Been Off Now Zzz...!*', 1, 'md')
redis:del(Mehdi.."markread:", true)
else
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*MarkRead Is Already Off Zzz...!*', 1, 'md')
end
end
if redis:get(Mehdi.."markread:") then
tdcli.viewMessages(chat_id, {[0] = msg.id_})
end
-------------------------------------------------------
if txt:match("^[Cc]heck$") and is_sudo(msg) then
loadfile("./bot.lua")()
io.popen("rm -rf ~/.telegram-cli/data/animation/*")
io.popen("rm -rf ~/.telegram-cli/data/audio/*")
io.popen("rm -rf ~/.telegram-cli/data/document/*")
io.popen("rm -rf ~/.telegram-cli/data/photo/*")
io.popen("rm -rf ~/.telegram-cli/data/sticker/*")
io.popen("rm -rf ~/.telegram-cli/data/temp/*")
io.popen("rm -rf ~/.telegram-cli/data/video/*")
io.popen("rm -rf ~/.telegram-cli/data/voice/*")
io.popen("rm -rf ~/.telegram-cli/data/profile_photo/*")
tdcli.sendChatAction(msg.chat_id_,'Typing')
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'Checked!' , 1, 'md')
end
-------------------------------------------------------
if txt:match("^[Hh]elp$") and is_sudo(msg) then
local text = [[
•• راهنمای ربات تینیگر تبچی ! :)‌ •• 
……………………………………………………
• دستور برای افزودن مدیر برای ربات
`setsudo`
• دستور برای غیرفعال کردن مدیر برای ربات
`remsudo`
……………………………………………………
• دستور جوین شدن ربات در گروه ها !
`autojoin on`
• دستور لغو جوین شدن ربات در گروه ها !
`autojoin off`
……………………………………………………
• دستور تیک دوم ( مشاهده پیام ها )
`markread on`
• دستور غیر فعال کردن تیک دوم ( مشاهده پیام ها )
`markread off`
……………………………………………………
• دستور امار ربات 
`stats`
• دستور ریلود کردن امار ربات
`reset stats`
……………………………………………………
• دستور خارج شدن ربات از همه گروه ها 
`leave all`
……………………………………………………
• دستور سیو کردن مخاطب 
`save`
……………………………………………………
• دستور برای مشاهده انلاین بودن ربات ( ربات اگر ریپ چت هم باشد پاسخ باید بدهد )
`ping`
……………………………………………………
• دستور اد کردن فرد به همه گروهای ربات
`addtoall`
……………………………………………………
• دستور شیر کردن شماره ربات 
`share`
……………………………………………………
کانال : @TinigerTabchi
سازنده : @SenatorRom
]]
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text , 1, 'md')
end
-------------------------------------------------------
if txt:match("^[Tt][Ii][Nn][Ii][Gg][Ee][Rr]$") then
tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*•• TiniGerTabchi ••*\n………………………………………………\n↻ Creator : @SenatorRom\n↻ Channel : @TinigerTabchi  Bot 1.1' , 1, 'md')
end
-------------------------------------------------------
end
-------------------------------------------------------
elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
tdcli_function ({
ID="GetChats",
offset_order_="9223372036854775807",
offset_chat_id_=0,
limit_=20
}, dl_cb, nil)
end
end
