const fs = require('node:fs');
const cryptojs = require('crypto-js');
const UTF8_BOM = "\u{FEFF}";

const password = 'bosmajorca24!'

let content = fs.readFileSync('hotelinfo.json').toString();
if (content.startsWith(UTF8_BOM)) {
    content = content.substring(UTF8_BOM.length);
}
let json = JSON.parse(content);
let encrypted = cryptojs.AES.encrypt(JSON.stringify(json), password).toString();
fs.writeFileSync('../src/assets/hotelinfo.txt', encrypted, { encoding: 'utf8' });

content = fs.readFileSync('guestinfo.json').toString();
if (content.startsWith(UTF8_BOM)) {
    content = content.substring(UTF8_BOM.length);
}
json = JSON.parse(content);
encrypted = cryptojs.AES.encrypt(JSON.stringify(json), password).toString();
fs.writeFileSync('../src/assets/guestinfo.txt', encrypted, { encoding: 'utf8' });

/*
content = fs.readFileSync('timetable.json').toString();
if (content.startsWith(UTF8_BOM)) {
    content = content.substring(UTF8_BOM.length);
}
json = JSON.parse(content);
encrypted = cryptojs.AES.encrypt(JSON.stringify(json), password).toString();
fs.writeFileSync('../src/assets/timetable.txt', encrypted, { encoding: 'utf8' });
*/

content = fs.readFileSync('teachers.json').toString();
if (content.startsWith(UTF8_BOM)) {
    content = content.substring(UTF8_BOM.length);
}
json = JSON.parse(content);
encrypted = cryptojs.AES.encrypt(JSON.stringify(json), password).toString();
fs.writeFileSync('../src/assets/teachers.txt', encrypted, { encoding: 'utf8' });

encrypted = cryptojs.AES.encrypt(password, password).toString();
fs.writeFileSync('../src/assets/password.txt', encrypted, { encoding: 'utf8' });
