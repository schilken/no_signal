import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_signal/providers/user_data.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../api/remote_function_call_notifier.dart';
import '../../api/remote_function_caller.dart';

//  Link for the GitHub repo
final githubUrlProvider = Provider<String>((ref) {
  return 'https://github.com/2002Bishwajeet/no_signal';
});

class SettingsScreen extends ConsumerWidget {
  static const routename = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(currentLoggedUserProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: userData?.image != null
                        ? MemoryImage(userData!.image!) as ImageProvider
                        : const AssetImage('assets/images/avatar.png'),
                  ),
                  Expanded(
                    child: ListTile(
                      visualDensity: const VisualDensity(vertical: 2),
                      title: Text(userData?.name ?? 'No name',
                          style: Theme.of(context).textTheme.headline5),
                      subtitle: Text(
                        userData?.email ?? 'No email',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const ListTile(
              title: Text('Account'),
              leading: Icon(Icons.account_circle),
            ),
            const ListTile(
              title: Text('Linked devices'),
              leading: Icon(Icons.link),
            ),
            const Divider(
              height: 19,
            ),
            const ListTile(
              title: Text('Appearance'),
              leading: Icon(Icons.color_lens),
            ),
            const ListTile(
              title: Text('Chats'),
              leading: Icon(Icons.chat),
            ),
            const ListTile(
              title: Text('Notifications'),
              leading: Icon(Icons.notifications),
            ),
            const ListTile(
              title: Text('Privacy'),
              leading: Icon(Icons.lock),
            ),
            const ListTile(
              title: Text('Data and storage'),
              leading: Icon(Icons.storage),
            ),
            const Divider(),
            ListTile(
                title: Text('Call remote func02'),
              leading: Icon(Icons.help),
                onTap: () async {
                  final remoteCaller = await ref
                      .read(remoteFunctionCallNotifierProvider.notifier)
                      .callRemoteFunction('func02');
                }
            ),
            Consumer(builder: (context, ref, child) {
              debugPrint('build: Consumer for ListTile');
              final callerState = ref.watch(remoteFunctionCallNotifierProvider);
              return ListTile(
                  title: Text('Count all messages: $callerState'),
                  leading: Icon(Icons.mail),
                  onTap: () async {
                    final remoteCaller = await ref
                        .read(remoteFunctionCallNotifierProvider.notifier)
                        .callRemoteFunction('countMessages');
                  });
            }
            ),
            ListTile(
              title: const Text('Link to repo'),
              trailing: const Icon(Icons.link),
              leading: const FaIcon(FontAwesomeIcons.github),
              onTap: () => _launchURL(ref.read(githubUrlProvider)),
            ),
          ],
        ),
      ),
    );
  }
}
