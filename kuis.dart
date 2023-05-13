import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Event parent kelas abstrak
abstract class JenisPinjamanEvent {}

// Event untuk fetch data jenis pinjaman
class FetchJenisPinjamanEvent extends JenisPinjamanEvent {
  final int jenisPinjamanId;

  FetchJenisPinjamanEvent(this.jenisPinjamanId);
}

// State class
class JenisPinjamanState {
  final List<JenisPinjaman> jenisPinjamanList;

  JenisPinjamanState(this.jenisPinjamanList);
}

class JenisPinjamanBloc extends Bloc<JenisPinjamanEvent, JenisPinjamanState> {
  JenisPinjamanBloc() : super(JenisPinjamanState([])) {
    on<FetchJenisPinjamanEvent>((event, emit) {
      fetchData(event.jenisPinjamanId);
    });
  }

  void fetchData(int jenisPinjamanId) async {
    String url = 'http://178.128.17.76:8000/jenis_pinjaman/$jenisPinjamanId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<JenisPinjaman> jenisPinjamanList = jsonResponse['data']
          .map<JenisPinjaman>(
              (jenisPinjaman) => JenisPinjaman.fromJson(jenisPinjaman))
          .toList();
      emit(JenisPinjamanState(jenisPinjamanList));
    } else {
      throw Exception('Failed to load jenis pinjaman');
    }
  }
}

class JenisPinjaman {
  String id;
  String name;

  JenisPinjaman({required this.id, required this.name});

  factory JenisPinjaman.fromJson(Map<String, dynamic> json) {
    return JenisPinjaman(
      id: json['id'],
      name: json['nama'],
    );
  }
}

// Event parent kelas abstrak
abstract class DetilJenisPinjamanEvent {}

// Event untuk fetch data detil jenis pinjaman
class FetchDetilJenisPinjamanEvent extends DetilJenisPinjamanEvent {
  final String id;

  FetchDetilJenisPinjamanEvent(this.id);
}

// State class
class DetilJenisPinjamanState {
  final DetilJenisPinjaman? detilJenisPinjaman;

  DetilJenisPinjamanState(this.detilJenisPinjaman);
}

class DetilJenisPinjamanBloc
    extends Bloc<DetilJenisPinjamanEvent, DetilJenisPinjamanState> {
  DetilJenisPinjamanBloc() : super(DetilJenisPinjamanState(null)) {
    on<FetchDetilJenisPinjamanEvent>((event, emit) {
      fetchData(event.id);
    });
  }

  void fetchData(String id) async {
    final response = await http
        .get(Uri.parse('http://178.128.17.76:8000/detil_jenis_pinjaman/$id'));

    if (response.statusCode == 200) {
      DetilJenisPinjaman detilJenisPinjaman =
          DetilJenisPinjaman.fromJson(jsonDecode(response.body));
      emit(DetilJenisPinjamanState(detilJenisPinjaman));
    } else {
      throw Exception('Failed to load detil jenis pinjaman');
    }
  }
}

class DetilJenisPinjaman {
  final String id;
  final String name;
  final String bunga;
  final String isSyariah;

  DetilJenisPinjaman({
    required this.id,
    required this.name,
    required this.bunga,
    required this.isSyariah,
  });

  factory DetilJenisPinjaman.fromJson(Map<String, dynamic> json) {
    return DetilJenisPinjaman(
      id: json['id'],
      name: json['nama'],
      bunga: json['bunga'],
      isSyariah: json['is_syariah'],
    );
  }
}

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => JenisPinjamanBloc()),
        BlocProvider(create: (context) => DetilJenisPinjamanBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String nim1 = '2106791';
  final String nim2 = '2100506';

  final String nama1 = "Rachman Faiz Maulana";
  final String nama2 = "Destira Lestari Saraswati";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My APP P2P',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My APP P2P'),
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Kelompok 16',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '1. Nim: $nama1, NIM: $nim1',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '2. Nama: $nama2, NIM: $nim2',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'Saya Berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang',
                                    style: TextStyle(fontSize: 20)),
                              )))),
                ],
              ),
            ),
            JenisPinjamanDropDown(),
            Expanded(child: JenisPinjamanList()),
          ],
        ),
      ),
    );
  }
}

class JenisPinjamanDropDown extends StatefulWidget {
  @override
  _JenisPinjamanDropDownState createState() => _JenisPinjamanDropDownState();
}

class _JenisPinjamanDropDownState extends State<JenisPinjamanDropDown> {
  String dropdownValue = 'Pilih Jenis Pinjaman';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<String>(
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
          if (newValue == 'Jenis Pinjaman 1') {
            newValue = '1';
          } else if (newValue == 'Jenis Pinjaman 2') {
            newValue = '2';
          } else if (newValue == 'Jenis Pinjaman 3') {
            newValue = '3';
          }
          int jenisPinjamanId = int.parse(newValue!);
          context
              .read<JenisPinjamanBloc>()
              .add(FetchJenisPinjamanEvent(jenisPinjamanId));
        },
        items: <String>[
          'Pilih Jenis Pinjaman',
          'Jenis Pinjaman 1',
          'Jenis Pinjaman 2',
          'Jenis Pinjaman 3',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

class JenisPinjamanList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JenisPinjamanBloc, JenisPinjamanState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.jenisPinjamanList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: Image.network('https://picsum.photos/200'),
                title: Text(state.jenisPinjamanList[index].name),
                subtitle: Row(
                  children: [
                    Text('id: '),
                    Text(state.jenisPinjamanList[index].id),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                 
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailPage(id: state.jenisPinjamanList[index].id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class DetailPage extends StatefulWidget {
  final String id;

  DetailPage({required this.id});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<DetilJenisPinjamanBloc>()
        .add(FetchDetilJenisPinjamanEvent(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Jenis Pinjaman'),
      ),
      body: Center(
        child: BlocBuilder<DetilJenisPinjamanBloc, DetilJenisPinjamanState>(
          builder: (context, state) {
            if (state.detilJenisPinjaman != null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ID: ${state.detilJenisPinjaman!.id}'),
                  Text('Nama: ${state.detilJenisPinjaman!.name}'),
                  Text('Bunga: ${state.detilJenisPinjaman!.bunga}'),
                  Text('Is Syariah: ${state.detilJenisPinjaman!.isSyariah}'),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
