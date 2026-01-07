import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/version_checker.dart';

class UpdateDialog extends StatelessWidget {
  final VersionInfo versionInfo;
  
  const UpdateDialog({
    super.key,
    required this.versionInfo,
  });
  
  @override
  Widget build(BuildContext context) {
    // Get title from API or use default based on type
    String title = versionInfo.title ?? 
                   (versionInfo.isNews ? 'Pemberitahuan Baru' : 'Versi Terkini Tersedia');
    String message = versionInfo.message;
    
    // Button text based on whether there's a link
    final hasLink = versionInfo.downloadLink.isNotEmpty;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 171, 255, 102),
              Color.fromARGB(255, 65, 169, 44),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rocket/Update Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                versionInfo.isNews ? Icons.announcement : Icons.rocket_launch,
                size: 40,
                color: Color.fromARGB(255, 32, 104, 56),
              ),
            ),
            
            SizedBox(height: 20),
            
            // White content container
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  // Show version info only if it's an update (not news)
                  if (!versionInfo.isNews) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            versionInfo.currentVersion,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16, color: Colors.grey[400]),
                          SizedBox(width: 8),
                          Text(
                            versionInfo.latestVersion,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 83, 125, 56),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 20),
                  
                  // Buttons
                  Row(
                    children: [
                      // Abaikan button
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            // Dismiss this version/news
                            await VersionChecker.dismissUpdate(
                              versionInfo.isNews 
                                ? 'news_${versionInfo.message.hashCode}' 
                                : versionInfo.latestVersion
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Abaikan',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Update/OK button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (hasLink) {
                              final url = Uri.parse(versionInfo.downloadLink);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Color.fromARGB(255, 70, 126, 32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            versionInfo.isNews ? 'OK' : 'Update',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show update dialog
  static Future<void> show(BuildContext context, VersionInfo versionInfo) async {
    // For news, use message hash as identifier. For updates, use version
    final identifier = versionInfo.isNews 
        ? 'news_${versionInfo.message.hashCode}' 
        : versionInfo.latestVersion;
    
    print('🔍 Checking if notification was dismissed: $identifier');
    
    // Don't show if user already dismissed this
    final dismissed = await VersionChecker.hasUserDismissedUpdate(identifier);
    if (dismissed) {
      print('⏭️  Notification already dismissed by user, skipping');
      return;
    }
    
    print('✅ Showing dialog for: $identifier');
    
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => UpdateDialog(versionInfo: versionInfo),
      );
    }
  }
}

