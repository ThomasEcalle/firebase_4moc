import 'package:flutter/material.dart';
import 'package:moc_4/user.dart';

class UserItem extends StatelessWidget {
  final User user;

  const UserItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${user.firstName} ${user.lastName}"),
    );
  }
}
