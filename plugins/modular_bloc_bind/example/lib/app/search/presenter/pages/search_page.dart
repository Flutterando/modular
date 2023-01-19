import 'package:example/app/search/domain/entities/result.dart';
import 'package:example/app/search/domain/errors/erros.dart';
import 'package:example/app/search/presenter/blocs/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../events/search_event.dart';
import '../states/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Widget _buildList(ListedSearchState state) {
    final list = state.list;
    if (list.isEmpty) {
      return const Center(
        child: Text('Please, type something...'),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, index) {
        var item = list[index];
        return ListTile(
          leading: Hero(
            tag: item.image,
            child: CircleAvatar(
              backgroundImage: NetworkImage(item.image),
            ),
          ),
          title: Text(item.nickname),
          onTap: () {
            Modular.to.pushNamed('/details?id=1', arguments: item);
          },
        );
      },
    );
  }

  Widget _buildError(ErrorState error) {
    if (error is EmptyList) {
      return const Center(
        child: Text('Nothing has been found'),
      );
    } else if (error is ErrorSearch) {
      return const Center(
        child: Text('Github error'),
      );
    } else {
      return const Center(
        child: Text('Internal error'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SearchBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Github Search'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
            child: TextField(
              onChanged: (text) {
                bloc.add(ByTextSearchEvent(text));
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search...',
              ),
            ),
          ),
          Expanded(
            child: bloc.state.when(
              onState: _buildList,
              onLoading: () => const Center(child: CircularProgressIndicator()),
              onError: _buildError,
            ),
          ),
        ],
      ),
    );
  }
}
