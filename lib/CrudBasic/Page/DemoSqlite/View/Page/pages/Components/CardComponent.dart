import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:flutter/material.dart';

class CardComponent extends StatelessWidget {
  const CardComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: ConfigurationApp.whiteColor,
        child: GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: Image.asset('assets/images/avatar.jpg',
                fit: BoxFit.cover, height: 50, width: 50),
            title: Text('Here is Product Title',
                style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text(
              'Here is the description of this project, kindly read it carefully.',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Wrap(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit,
                      color: ConfigurationApp.successColor,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
              ],
            ),
          ),
        ));
  }
}
