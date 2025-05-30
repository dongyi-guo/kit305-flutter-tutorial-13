import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'movie_details.dart';
import 'movie.dart';

Future main() async{

  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print("\n\nConnected to Firebase App ${app.options.projectId}.\n\n");
  runApp(const MyApp());

}

class MyApp extends StatelessWidget
{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //BEGIN: the old MyApp builder from last week
    return ChangeNotifierProvider(
        create: (context) => MovieModel(),
        child: MaterialApp(
            title: 'Database Tutorial',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(title: 'Database Tutorial'),
            debugShowCheckedModeBanner: false,
        )
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
    return Consumer<MovieModel>(
        builder:buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, MovieModel movieModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return const MovieDetails();
          });
        },
        tooltip: 'Add Movie',
        child: const Icon(Icons.add),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            //YOUR UI HERE
            if (movieModel.loading) const CircularProgressIndicator() else Expanded(
              child: RefreshIndicator(
                onRefresh: () => movieModel.fetch(),
                child: ListView.builder(
                    itemBuilder: (_, index) {
                      var movie = movieModel.items[index];
                      var image = movie.image;
                      return Dismissible(
                        key: Key(movie.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          await movieModel.delete(movie.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${movie.title} deleted")));
                        },
                        child: ListTile(
                          title: Text(movie.title),
                          subtitle: Text("${movie.year} - ${movie.duration} Minutes"),
                          leading: image != null ? Image.network(image) : null,

                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return MovieDetails(id: movie.id);
                                }));
                          },
                        ),
                      );
                    },
                    itemCount: movieModel.items.length
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
