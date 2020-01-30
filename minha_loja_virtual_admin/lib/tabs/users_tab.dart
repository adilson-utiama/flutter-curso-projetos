import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:minha_loja_virtual_admin/blocs/user_bloc.dart';
import 'package:minha_loja_virtual_admin/widgets/tiles/user_tile.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userBloc = BlocProvider.getBloc<UserBloc>();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: "Pesquisar",
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                border: InputBorder.none
            ),
            onChanged: _userBloc.onChangedSearch,
          ),
        ),
        Expanded(
          child: StreamBuilder<List>(
              stream: _userBloc.outUsers,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
                    ),
                  );
                } else if (snapshot.data.length == 0) {
                  return Center(
                    child: Text(
                      "Nenhum usuario encontrado!",
                      style: TextStyle(color: Colors.pinkAccent),
                    ),
                  );
                }else{
                  return ListView.separated(
                      itemBuilder: (context, index) {
                        return UserTile(
                            user: snapshot.data[index]
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: snapshot.data.length);
                }


              }),
        )
      ],
    );
  }
}
