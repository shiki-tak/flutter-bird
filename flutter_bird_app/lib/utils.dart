import 'dart:html' as html;

bool isMobileWeb() {
  final userAgent = html.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('mobile') || 
         userAgent.contains('android') || 
         userAgent.contains('ios');
}
