import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'team_model.dart';
import 'team_details.dart';

class TeamListPage extends StatelessWidget {
  const TeamListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TeamDetails()));
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Consumer<TeamModel>(
        builder: (_, model, __) {
          if (model.loading) return const Center(child: CircularProgressIndicator());
          return RefreshIndicator(
            onRefresh: model.fetch,
            child: ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (_, index) {
                var team = model.items[index];
                return ListTile(
                  title: Text(team.name),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TeamDetails(id: team.id)));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
