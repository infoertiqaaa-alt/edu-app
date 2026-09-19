import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

class StudentAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const StudentAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final url = ApiConstants.resolveImageUrl(imageUrl);
    final hasImage = url != null && url.isNotEmpty;
    final fallback = Icon(
      Icons.person,
      size: radius * 1.2,
      color: Colors.black26,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: radius - 3,
        backgroundColor: const Color(0xFFEFEFEF),
        child: ClipOval(
          child: hasImage
              ? Image.network(
                  url,
                  width: (radius - 3) * 2,
                  height: (radius - 3) * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                )
              : fallback,
        ),
      ),
    );
  }
}
