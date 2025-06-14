import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'match_briefing.dart';
import 'model/match_model.dart';
import 'model/afl_models.dart';
import 'new_match_flow.dart';

Future main() async{

  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //BEGIN: the old MyApp builder from last week
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchModel()),
      ],
      child: MaterialApp(
            title: 'AFL Counter',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(title: 'AFL Counter'),
            debugShowCheckedModeBanner: false,
      ),
    );
    //END: the old MyApp builder from last week
  }
}

class MyHomePage extends StatefulWidget
{
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage>
{
  @override
  Widget build(BuildContext context) {
    return Consumer<MatchModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, MatchModel matchModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NewMatchFlow()));
        },
        tooltip: 'Add Match',
        child: const Icon(Icons.add),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            //YOUR UI HERE
            if (matchModel.loading)
              const CircularProgressIndicator()
            else if (matchModel.items.isEmpty)
              const Text('No matches yet')
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => matchModel.fetch(),
                  child: ListView.builder(
                      itemBuilder: (_, index) {
                        var match = matchModel.items[index];
                        String scoreFor(List<Player> players) {
                          int goals = 0;
                          int behinds = 0;
                          for (var p in players) {
                            for (var a in p.actions) {
                              if (a.type == ActionType.goal) goals++;
                              if (a.type == ActionType.behind) behinds++;
                            }
                          }
                          int total = goals * 6 + behinds;
                          return '$goals.$behinds ($total)';
                        }
                        var score =
                            '${scoreFor(match.teamAPlayers)} vs ${scoreFor(match.teamBPlayers)}';
                        return Dismissible(
                          key: Key(match.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) async {
                            await matchModel.delete(match.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Match deleted")));
                          },
                          child: ListTile(
                            title: Text("${match.teamAName} vs ${match.teamBName}"),
                            subtitle: Text(score),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          MatchBriefingPage(matchId: match.id)));
                            },
                          ),
                        );
                      },
                      itemCount: matchModel.items.length
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}
