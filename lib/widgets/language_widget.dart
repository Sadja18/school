import 'package:flutter/material.dart';
import '../services/database_handler.dart';

class LanguageDropDown extends StatefulWidget {
  final Function(String?) selectLanguage;
  final String? className;
  const LanguageDropDown(
      {Key? key, required this.className, required this.selectLanguage})
      : super(key: key);

  @override
  _LanguageDropDownState createState() => _LanguageDropDownState();
}

class _LanguageDropDownState extends State<LanguageDropDown> {
  String? _selectedLanguage = '';
  Future<dynamic> getAllLangs() {
    return DBProvider.db.getAllLanguages(widget.className).then((languages) {
      return languages.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getAllLangs(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Text('Loading');
            } else {
              var mediums = snapshot.data;
              // print(mediums);
              List<String> mediumNames = [];
              for (var medium in mediums) {
                mediumNames.add(medium['langName']);
                // print(medium['medium_id']);
              }
              return DropdownButton<String>(
                hint: const Text('Select Language'),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurpleAccent),
                value: _selectedLanguage!.isNotEmpty ? _selectedLanguage : null,
                // ignore: prefer_const_literals_to_create_immutables
                items: mediumNames.map<DropdownMenuItem<String>>(
                  (String element) {
                    return DropdownMenuItem<String>(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          element,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      value: element,
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value as String;
                  });
                  widget.selectLanguage(value.toString());
                },
              );
            }
          } else {
            return const Text('No medium in this class');
          }
        });
  }
}
