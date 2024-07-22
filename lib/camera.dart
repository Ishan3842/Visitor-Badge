import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:http/http.dart' as http;
import 'badge_page.dart';
import 'config_manager.dart';

class CameraPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String? middleName;
  final String dateOfBirth;
  final String gender;
  final String height;
  final String expiryDate;
  final String issueDate;
  final String address;
  final String state;
  final String country;
  final String idNumber;
  final String? badgeExpiry;
  final int? companyId;
  final int? locationId;
  final String visitingWhom;
  final String purpose;

  const CameraPage({
    Key? key,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.expiryDate,
    required this.issueDate,
    required this.address,
    required this.state,
    required this.country,
    required this.idNumber,
    this.badgeExpiry,
    this.companyId,
    this.locationId,
    required this.visitingWhom,
    required this.purpose,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _capturedImage;
  late FaceCameraController controller;

  @override
  void initState() {
    super.initState();
    controller = FaceCameraController(
      autoCapture: false,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        setState(() => _capturedImage = image);
      },
      onFaceDetected: (Face? face) {
        // You can add face detection logic here if needed
      },
    );
  }

  Future<void> _uploadBadge() async {
    if (_capturedImage == null) return;

    final url = Uri.parse(
        '${ConfigManager.apiBaseUrl}${ConfigManager.addVisitorEndpoint}');
    var request = http.MultipartRequest('POST', url);

    request.files
        .add(await http.MultipartFile.fromPath('photo', _capturedImage!.path));
    request.fields['first_name'] = widget.firstName;
    request.fields['middle_name'] = widget.middleName ?? '';
    request.fields['last_name'] = widget.lastName;
    request.fields['visiting_whom'] = widget.visitingWhom;
    request.fields['purpose'] = widget.purpose;
    request.fields['date_of_birth'] = widget.dateOfBirth;
    request.fields['height'] = widget.height;
    request.fields['gender'] = widget.gender;
    request.fields['id_number'] = widget.idNumber;
    request.fields['issue_date'] = widget.issueDate;
    request.fields['expiry_date'] = widget.expiryDate;
    request.fields['state'] = widget.state;
    request.fields['country'] = widget.country;
    request.fields['address'] = widget.address;
    request.fields['company_id'] = widget.companyId?.toString() ?? '';
    request.fields['location_id'] = widget.locationId?.toString() ?? '';
    request.fields['badge_expiry'] = widget.badgeExpiry ?? '';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Badge uploaded successfully');
      } else {
        print('Failed to upload badge: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading badge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Your Photo'),
        backgroundColor: ConfigManager.primaryColor,
      ),
      body: Center(
        child: Builder(builder: (context) {
          if (_capturedImage != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: ConfigManager.primaryColor, width: 2),
                  ),
                  child: Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await controller.startImageStream();
                        setState(() => _capturedImage = null);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: ConfigManager.primaryColor,
                      ),
                      child: const Text('Retake Photo'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _uploadBadge();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BadgePage(
                              imagePath: _capturedImage!.path,
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              badgeExpiry: widget.badgeExpiry,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: ConfigManager.primaryColor,
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            );
          }
          return Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: ConfigManager.primaryColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SmartFaceCamera(
                controller: controller,
                showCameraLensControl: false,
                showFlashControl: false,
                messageBuilder: (context, face) {
                  if (face == null) {
                    return _message('Place your face in the camera');
                  }
                  if (!face.wellPositioned) {
                    return _message('Center your face in the frame');
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: Colors.white),
        ),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'badge_page.dart';
import 'config_manager.dart';

class CameraPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String? badgeExpiry;

  const CameraPage({
    Key? key,
    required this.firstName,
    required this.lastName,
    this.badgeExpiry,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _capturedImage;
  late FaceCameraController controller;

  @override
  void initState() {
    super.initState();
    controller = FaceCameraController(
      autoCapture: false,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        setState(() => _capturedImage = image);
      },
      onFaceDetected: (Face? face) {
        // You can add face detection logic here if needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Your Photo'),
        backgroundColor: ConfigManager.primaryColor,
      ),
      body: Center(
        child: Builder(builder: (context) {
          if (_capturedImage != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: ConfigManager.primaryColor, width: 2),
                  ),
                  child: Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await controller.startImageStream();
                        setState(() => _capturedImage = null);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: ConfigManager.primaryColor,
                      ),
                      child: const Text('Retake Photo'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BadgePage(
                              imagePath: _capturedImage!.path,
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              badgeExpiry: widget.badgeExpiry,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: ConfigManager.primaryColor,
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            );
          }
          return Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: ConfigManager.primaryColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SmartFaceCamera(
                controller: controller,
                showCameraLensControl: false,
                showFlashControl: false,
                messageBuilder: (context, face) {
                  if (face == null) {
                    return _message('Place your face in the camera');
                  }
                  if (!face.wellPositioned) {
                    return _message('Center your face in the frame');
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: Colors.white),
        ),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
*/