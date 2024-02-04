const express = require('express');
const {connection} = require('./database/database');
const http = require('http');
const app = express();
const axios = require('axios'); 
const PORT = 4000;
app.use(express.json());



app.get("/history", async (req, res) => {
    const today = new Date();
const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0);
const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1, 0, 0, 0);

const historyQuery = `
  SELECT title, DATE_FORMAT(subtitle, "%d.%m.%Y %H:%i:%s") AS subtitle, isopened
  FROM history
  WHERE subtitle >= ? AND subtitle < ?
  ORDER BY subtitle DESC
`;

const [result] = await connection.promise().query(historyQuery, [startOfDay, endOfDay]);
console.log(result);
res.status(200).json(result);




});

app.post("/warn", async(req, res) => {
const {data} = req.body;
console.log("****************************************" + data)
const insertUserQuery = 'INSERT INTO history (title, isopened) VALUES (?, ?)';
let str;
if(data == 0){
str = "Kapı kapatıldı.";
}else {
    str = "Kapı Açıldı."
}
await connection.promise().query(insertUserQuery, [str, data]);

    const statusQuery = "UPDATE status SET status = ?, lastopen = CURRENT_TIMESTAMP WHERE id = ?";
    const queryParams = [data, 0]; // Örnek parametre değerleri
    
    await connection.promise().query(statusQuery, queryParams);

    const selectQuery2 = 'SELECT sound, ms, alarm FROM settings WHERE id = ?';
    const queryParams2 = [0]; // Güncellenmek istenen kaydın id'si
    const [rows] = await connection.promise().query(selectQuery2, queryParams2);
    
    axios.post("https://fcm.googleapis.com/fcm/send", {
  "to": "/topics/door0",
  "notification": {
    "title": "Uyarı !",
    "body": str
  },
  "data": {
    "data": data
  }
}, {
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'key=AAAAGoWyh0c:APA91bFxvgGhEl5ZbTInGnsyXJD_oXgCzPbRndC7Di84Uc46tpwdIzPBaHtxQN5cwOV7OXNE6ViZ-LT9-Bc1-OUbxhR_0RWMQfCB2JerQVmVA5kM06212YQZ72NJOTUP_JPjNHF_P57R' // FCM server key'i buraya ekleyin
  }
}).then((response) => {
  console.log(res.data);
  if(rows[0].alarm == 1 && data == 0){
    rows[0].alarm = 0;
    
  }
  res.status(200).json({sound: rows[0].sound, ms: rows[0].ms, alarm: rows[0].alarm});
}).catch((error) => {
    console.log(error.message);
});
    





       

});

app.get("/status", async(req, res) => {
    const selectQuery = 'SELECT lastopen, status FROM status WHERE id = ?';
    const queryParams = [0]; // Güncellenmek istenen kaydın id'si

    const [rows] = await connection.promise().query(selectQuery, queryParams);

    const lastOpenTimestamp = new Date(rows[0].lastopen).getTime(); // Veritabanından alınan tarihi milisaniyeye çevir

  const now = new Date().getTime(); // Şu anki zamanı milisaniyeye çevir

  const differenceInMilliseconds = now - lastOpenTimestamp;

  const seconds = Math.floor(differenceInMilliseconds / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);




    res.status(200).json({result: rows[0].status, last: `${hours} saat, ${minutes % 60} dakika, ${seconds % 60} saniye`});
});


app.get("/settings", async (req, res) => {
    const selectQuery = 'SELECT sound, ms, alarm FROM settings WHERE id = ?';
    const queryParams = [0]; // Güncellenmek istenen kaydın id'si
    const [rows] = await connection.promise().query(selectQuery, queryParams);

    res.status(200).json({sound: rows[0].sound, ms: rows[0].ms, alarm: rows[0].alarm});


});

app.post("/settings", async (req, res) => {
    const {sound, ms, alarm} = req.body;
console.log(sound, ms, alarm);
    
    const selectQuery = 'UPDATE settings SET sound = ?, ms = ?, alarm = ? WHERE id = ?';
    const queryParams = [sound, ms, alarm, 0];
    const [rows] = await connection.promise().query(selectQuery, queryParams);

    res.status(200).json({result: "success"});


});


app.listen(PORT, ()  => {
    console.log(PORT + " portundan istemci isteği bekleniyor."  );
});