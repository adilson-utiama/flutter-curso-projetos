import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:minha_loja_virtual_admin/blocs/orders_bloc.dart';
import 'package:minha_loja_virtual_admin/blocs/user_bloc.dart';
import 'package:minha_loja_virtual_admin/screens/login_screen.dart';
import 'package:minha_loja_virtual_admin/tabs/orders_tab.dart';
import 'package:minha_loja_virtual_admin/tabs/products_tab.dart';
import 'package:minha_loja_virtual_admin/tabs/users_tab.dart';
import 'package:minha_loja_virtual_admin/widgets/edit_category_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  PageController _pageController;
  int _page = 0;

  UserBloc _userBloc;
  OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _userBloc = UserBloc();
    _ordersBloc = OrdersBloc();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loja Virtual Admin"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white,),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => LoginScreen()
              ));
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Colors.pinkAccent,
            primaryColor: Colors.white,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: TextStyle(color: Colors.white54))),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (page) {
            print(page);
            _pageController.animateToPage(page,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: Text("Clientes")),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), title: Text("Pedidos")),
            BottomNavigationBarItem(
                icon: Icon(Icons.list), title: Text("Produtos")),
          ],
        ),
      ),
      body: BlocProvider(
        blocs: [
          Bloc((_) => _userBloc),
          Bloc((_) => _ordersBloc),
        ],
        child: PageView(
          controller: _pageController,
          onPageChanged: (page){
            setState(() {
              _page = page;
            });
          },
          children: <Widget>[
            UsersTab(),
            OrdersTab(),
            ProductsTab()
          ],
        ),
      ),
      floatingActionButton: _buildFloating(),
    );
  }

  Widget _buildFloating() {
    switch(_page){
      case 0:
        return null;
    case 1:
      return SpeedDial(
        child: Icon(Icons.sort),
        backgroundColor: Colors.pinkAccent,
        overlayOpacity: 0.4,
        overlayColor: Colors.black,
        children: [
          SpeedDialChild(
            child: Icon(Icons.arrow_downward, color: Colors.pinkAccent,),
            backgroundColor: Colors.white,
            label: "Concluidos Abaixo",
            labelStyle: TextStyle(fontSize: 14),
            onTap: (){
              _ordersBloc.setOrderCriteria(SortCriteria.READY_LAST);
            }
          ),
          SpeedDialChild(
              child: Icon(Icons.arrow_upward, color: Colors.pinkAccent,),
              backgroundColor: Colors.white,
              label: "Concluidos Acima",
              labelStyle: TextStyle(fontSize: 14),
              onTap: (){
                _ordersBloc.setOrderCriteria(SortCriteria.READY_FIRST);
              }
          )
        ],
      );
      case 2:
        return FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.pinkAccent,
          onPressed: (){
            showDialog(context: context,
                builder: (context) => EditCategoryDialog());
          },
        );
    }
  }
}
