
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:geolocator/geolocator.dart';



void main() => runApp(MaterialApp(
  home:Home()
));


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Geolocator geolocator = Geolocator()
    ..forceAndroidLocationManager;

  String value = "error";

  String value1 = "error";

  String value2;

  String toDataBase;

  Position currentPosition;



  @override
  // bu methode Qr oluşturma sayfasına geçiş yaparken ekran görüntüsü alma işleminin bayrağını kesmek için

  //bu method lokasyonu cekiyor geolocator kütüphanesinden
  getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  //cette fonction control la distance user/center et rayon
  checkLocation() async{
    int _ctrl;
    getCurrentLocation();
    double lat =  currentPosition.latitude;//41.046485;
    double long = currentPosition.longitude;//29.020362;
    try{
    double rayon =  await Geolocator().distanceBetween(41.045885, 29.019987, 41.046902, 29.020752);
    double userDistance = await Geolocator().distanceBetween(41.045885, 29.019987, lat,long);

    if(userDistance>rayon){
      _ctrl = 1;
      return _ctrl;
    }
    else{
      _ctrl = 0;
      return _ctrl;
    }
      }catch(e){
      print(e);
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(// formation de l'échafaudage, le tron de l'arbre

      resizeToAvoidBottomPadding: false,
      appBar: AppBar( // formation de la bare de l'application
        title: Text(
          "GSÜ QR APP",
          style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.grey[200],
              fontFamily: 'Signi'
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset("assets/gsu_logo.png", // insertion du logo de l'université de Galatasaray
                height: 262.5,
                width: 175.0,
              ),
            ),
            Container(
              width: 320,
              child: TextFormField( //utilisé pour récolter le nom et le prénom de l'utilisateur
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  onChanged: (text) { //ici il y a une écoute permanente et un changement simultané de la variable
                    value = text;
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red[900],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: "İsim ve Soyisim.",
                    hintStyle: TextStyle(
                      color: Colors.red[900],
                    ),
                  )
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: 320,
              child: TextFormField( //utilisé pour récolter le nom et le numéro d'étudiant de l'utilisateur
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  onChanged: (text) {//ici il y a une écoute permanente et un changement simultané de la variable
                    value1 = text;
                  },

                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red[900],
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: "Öğrenci Numarası.",
                    hintStyle: TextStyle(
                      color: Colors.red[900],
                    ),
                  )
              ),
            ),
            Container(
              child: SizedBox(height: 30),
            ),
            Container(
                child: RaisedButton.icon(

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                                    ),
                  onPressed: () async{
                    int _ctrl = await checkLocation(); // _ctrl = 0 l'utilisateur est dans l'établissement _ctrl = 1 message erreur

                    if (value.length == 0 && value1.length == 0) {
                      value = "error";// si les entrée sont vide les valeurs défaut
                      value1 = "error";//sont "error"
                         }
                    DateTime now = DateTime.now();
                    value2 = DateFormat('yyyy-MM-dd – kk:mm').format(now);
                    // value, value1, value2 prénom, numéro d'étudiant, date et heure
                    //ce sont les valeurs à passer à la page de génération.


                    if(_ctrl == 0){
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            Qr(
                              value: value,
                              value1: value1,
                              value2: value2,
                            )
                        ),
                      );
                    }


                      else{ // bu koşul okul konumunda olunmadığı durum dialog mesaj vermekte
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(20.0)),
                              child: Container(
                                height: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Okul Konumunda Değilsiniz!'),

                                      ),
                                      SizedBox(
                                        width: 320.0,
                                        child: RaisedButton(
                                          onPressed: () {
                                                Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            "Tamam",
                                            style: TextStyle(
                                                color: Colors.grey[200]
                                            ),
                                          ),
                                          color: Colors.red[900],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                      }
                    },






                  icon: Icon(
                    Icons.select_all,
                    color: Colors.grey[200],
                  ),
                  color: Colors.red[900],
                  label: Text(
                    "Qr Kod oluştur !",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[200],
                    ),
                  ),

                )
            ),
            Container(
              child: SizedBox(height: 10),
            ),
            Container(
              child: InkWell(
                onTap: () {
                  return Alert(context: context,
                      title: "Kullanım Koşulları",
                      desc: "GSÜ QR app Kullanım Koşulları : 1-) GSÜ Yoklama mobil uygulamasında, öğrencilerin ilgili ders için QR kod oluşturması yalnızca okul sınırları içerisinde mümkündür. 2-) Oluşturulan QR kod kişiye özeldir, yoklama esnasında bir öğrencinin başka bir öğrenci yerine kod okutması mümkün değildir. 3-) Bir telefondan yalnızca tek bir QR kod oluşturulur, aynı telefon birden fazla kod okutma için kullanılamaz. 4-) Yukarıda belirtilen koşullardan biri ihlal edildiğinde veritabanında ilgili uyarılar oluşturulup, kural ihlali yapan öğrenci gerekli cezayı alacaktır.",
                      buttons: [
                        DialogButton(
                          child: Text(
                            "Tamam",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[200],
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ]
                  ).show();
                },
                child: Text(
                  "Kullanım Koşulları.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: Colors.red[900],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}














//2. sayfa class'ı
class Qr extends StatefulWidget {

  @override
  String value;
  String value1;
  String value2;
  Qr({
    this.value,
    this.value1,
    this.value2,
  });
  _QrState createState() => _QrState(
    value : value,
    value1 : value1,
    value2 : value2,

  );
}

class _QrState extends State<Qr> {
  String _platformImei = "Bilinmiyor";
  String uniqueId = "Bilinmiyor"; // altérnatif `æ l'imei (non utilisée)
  String value;
  String value1;
  String value2;

  _QrState({
    this.value,
    this.value1,
    this.value2,
  });

  void initState(){
    super.initState();
    initPlatformState();
  }
  Future<void> initPlatformState() async{
    String platformImei;
    String idunique;
    try{
      platformImei = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      idunique = await ImeiPlugin.getId();
    } on PlatformException {
      platformImei = "Hata x001";
    }
    // Si le widget a été supprimé de l'arborescence alors que la plateforme asynchrone
    // le message était en vol, nous voulons ignorer la réponse plutôt que d'appeler
    // setState pour mettre à jour notre apparence inexistante.
    if (!mounted) return;
    setState(() {
      _platformImei = platformImei;
      uniqueId = idunique;
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title : Text(
            "GSÜ QR APP",
            style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.grey[200],
                fontFamily: 'Signi'
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.red[900],
        ),
        body:Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: SizedBox(height: 20),
                ),
                 Container(

                   width:320,
                   height:50 ,
                   color: Colors.red[900],
                   child: Center(
                   child : Text(
                     value,
                     style: TextStyle(
                       fontSize: 37,
                       color: Colors.grey[200],
                     ),
                   ),
                 ),
                ),
                Container(
                  child: SizedBox(height: 20),
                ),
                Container(
                  width: 320,
                  height: 50,
                  color: Colors.red[900],
                  child : Center(
                  child: Text(
                    value1,
                    style: TextStyle(
                      fontSize: 37,
                      color: Colors.grey[200],
                    ),
                   ),
                  ),
                ),
                Container(
                  child: SizedBox(height: 20),
                ),
                Container(
                  child: QrImage(
                    //value 2 'yyyy-MM-dd – kk:mm'
                    data:  value +"/"+ value1 +   "/"+ value2 +"/"+_platformImei
                  )

                ),
              ],
            )
        ),
    );
  }
}






