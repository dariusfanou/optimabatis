import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:optimabatis/flutter_helpers/services/user_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final formKey = GlobalKey<FormState>();
  final lastnameController = TextEditingController();
  final firstnameController = TextEditingController();
  String? gender;
  TextEditingController dateController = TextEditingController();
  final emailController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _dateFormatStocked = DateFormat('yyyy-MM-dd');
  String? dateStocked;
  bool loading = false;

  String? _fileName;
  String? _filePath;

  Future<void> pickImage() async {
    // Ouvrir la fenêtre de sélection de fichiers pour les images
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Limite à l'image
    );

    if (result != null) {
      // Obtenir le chemin de l'image sélectionnée
      _filePath = result.files.single.path;
      _fileName = result.files.single.name;
      setState(() {});
    } else {
      // L'utilisateur a annulé la sélection
      print("Aucune image sélectionnée");
    }
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        locale: const Locale("fr")
    );

    if (picked != null) {
      dateController.text = _dateFormat.format(picked);
      dateStocked = _dateFormatStocked.format(picked);
    }
  }

  final userService = UserService();
  Map<String, dynamic>? authUser;
  bool isLoading = true;

  Future<void> getAuthUser() async {
    try {
      final user = await userService.getUser();
      setState(() {
        authUser = user;
        gender = authUser!["genre"];
        lastnameController.text = authUser!["last_name"];
        firstnameController.text = authUser!["first_name"];
        if (authUser!["datenaissance"] != null) {
          dateController.text = _dateFormat.format(authUser!["datenaissance"]);
        }
        if (authUser!["email"] != null) {
          emailController.text = authUser!["email"];
        }
        if(authUser!["photo"] != null) {
          _filePath = authUser!["photo"];
        }
        isLoading = false;
        print(authUser);
      });
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur : $e');
    }
  }

  updateUser() async {

    setState(() {
      loading = false;
    });

    try {

      Map<String, dynamic> data = {
        'email': emailController.text,
        "numtelephone": authUser!["numtelephone"],
        "first_name": firstnameController.text,
        'last_name': lastnameController.text,
        "genre": gender,
        "datenaissance": dateStocked
      };

      if (_filePath != null && _filePath!.isNotEmpty) {
        final File file = File(_filePath!);

        if (await file.exists()) {
          String mimeType = 'image/jpeg'; // Valeur par défaut (JPEG)
          String extension = _filePath!.split('.').last.toLowerCase(); // Récupère l'extension du fichier

          if (extension == 'png') {
            mimeType = 'image/png';
          }

          // Ajouter la photo dans les données
          data['photo'] = await MultipartFile.fromFile(_filePath!, contentType: DioMediaType.parse(mimeType));
        } else {
          print('Le fichier photo n\'existe pas.');
        }
      } else {
        print('Aucun fichier photo trouvé.');
      }

      await userService.updateUser(data);

      lastnameController.text = "";
      firstnameController.text = "";
      dateController.text = "";
      emailController.text = "";

      Fluttertoast.showToast(msg: "Profil modifié avec succès");

      context.go("/profile");

    } on DioException catch (e) {
      // Gérer les erreurs de la requête
      print(e.response?.statusCode);
      if (e.response != null) {
          Fluttertoast.showToast(msg: "Erreur du serveur : ${e.response?.statusCode}");
      } else {
        // Gérer les erreurs réseau
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          Fluttertoast.showToast(msg: "Temps de connexion écoulé. Vérifiez votre connexion Internet.");
        } else if (e.type == DioExceptionType.unknown) {
          Fluttertoast.showToast(msg: "Impossible de se connecter au serveur. Vérifiez votre réseau.");
        } else {
          Fluttertoast.showToast(msg: "Une erreur est survenue.");
        }
      }
    } catch (e) {
      // Gérer d'autres types d'erreurs
      Fluttertoast.showToast(msg: "Une erreur inattendue s'est produite.");
    }

  }

  @override
  void initState() {
    super.initState();
    getAuthUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            GoRouter.of(context).pop();
          },
          child: Row(
            children: [
              SizedBox(width: 28,),
              Expanded(
                  child: Image.asset("assets/images/back.png")
              )
            ],
          ),
        ),
      ),
      body: isLoading ?
      const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(left: 32, right: 32, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Modifier mon profil",
                    style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                        fontSize: 19
                    ),
                  ),
                  SizedBox(height: 16,),
                  Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: lastnameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "Entrez votre nom *",
                              hintStyle: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 13
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF707070)),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF707070)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Image.asset("assets/images/person.png"),
                            ),
                            validator: (value) {
                              return (value == null || value.isEmpty) ? "Veuillez entrer votre nom" : null;
                            },
                          ),
                          SizedBox(height: 16,),
                          TextFormField(
                            controller: firstnameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "Entrez votre(vos) prénom(s) *",
                              hintStyle: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 13
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF707070)),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF707070)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Image.asset("assets/images/person.png"),
                            ),
                            validator: (value) {
                              return (value == null || value.isEmpty) ? "Veuillez entrer votre(vos) prénom(s)" : null;
                            },
                          ),
                          SizedBox(height: 16,),
                          DropdownButtonFormField(
                            value: gender,
                            items: const [
                              DropdownMenuItem(
                                value: "homme",
                                child: Text("Masculin"),
                              ),
                              DropdownMenuItem(
                                value: "femme",
                                child: Text("Féminin"),
                              ),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                gender = value;
                              });
                            },
                            validator: (String? value) {
                              return (value == null || value == "") ? "Veuillez choisir un genre" : null;
                            },
                            hint: Center(
                              child: Text('Choisissez un genre *',
                                style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Image.asset("assets/images/gender.png"),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF707070)),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF707070)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 16,),
                          TextFormField(
                            controller: dateController,
                            decoration: InputDecoration(
                              hintText: "Entrez votre date de naissance",
                              hintStyle: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 13
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF707070)),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF707070)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Image.asset("assets/images/calendar.png"),
                            ),
                            readOnly: true,
                            onTap: () {
                              selectDate();
                            },
                          ),
                          SizedBox(height: 16,),TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF4B5563), size: 29,),
                              hintText: "monmail@monmail.com",
                              hintStyle: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 13
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF707070)),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF707070)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                              if (value != null && value.isNotEmpty && !emailRegex.hasMatch(value)) {
                                return "Veuillez entrer un email valide";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16,),
                          DottedBorder(
                              strokeWidth: 2,
                              borderType: BorderType.RRect,
                              color: Color(0xFF707070),
                              dashPattern: [5, 2],
                              radius: Radius.circular(16),
                              child: SizedBox(
                                width: double.infinity,
                                height: 64,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(16))
                                        ),
                                        backgroundColor: Color(0x3A3172B8)
                                    ),
                                    onPressed: () {
                                      pickImage();
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        (_filePath != null) ?
                                        Image.file(File(_filePath!)):
                                        Icon(Icons.person_outline, color: Color(0xFF4B5563), size: 28,),
                                        SizedBox(width: 10,),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Ajoutez une photo de profil",
                                                style: TextStyle(
                                                    color: Color(0xFF4B5563),
                                                    fontSize: 13
                                                ),
                                              ),
                                              Text("Photo de profil",
                                                style: TextStyle(
                                                    color: Color(0xFF3172B8),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              )
                          ),
                          SizedBox(height: 32,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Color(0xFF3172B8)),
                                  elevation: WidgetStatePropertyAll(0),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        side: BorderSide(color: Color(0xFF707070), width: 1),
                                      )
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(Colors.white)
                              ),
                              onPressed: () async {
                                if(formKey.currentState!.validate()) {
                                  await updateUser();
                                }
                              },
                              child: loading ?
                                SizedBox(
                                  height: 19,
                                  width: 19,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)
                                ) :
                                Text("Modifier",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                            ),
                          ),
                        ]
                      ),
                  ),
                ]
              )
          ),
      )
    );
  }
}
