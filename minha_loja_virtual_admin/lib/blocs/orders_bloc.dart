import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria { READY_FIRST, READY_LAST }

class OrdersBloc extends BlocBase {

  final _ordersController = BehaviorSubject<List>();

  Stream<List> get outOrders => _ordersController.stream;

  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _orders = [];

  SortCriteria _criteria;

  OrdersBloc(){
    _addOrdersListener();
  }

  @override
  void dispose() {
    _ordersController.close();
    super.dispose();
  }

  void setOrderCriteria(SortCriteria criteria){
    _criteria = criteria;
    _sort();
  }

  void _sort() {
      switch(_criteria){
        case SortCriteria.READY_FIRST:
          _orders.sort(
              (a, b){
                int sa = a.data["status"];
                int sb = b.data["status"];
                if(sa < sb){
                  return 1;
                }else if(sa > sb){
                  return -1;
                }else{
                  return 0;
                }
              }
          );
          break;
        case SortCriteria.READY_LAST:
          _orders.sort(
                  (a, b){
                int sa = a.data["status"];
                int sb = b.data["status"];
                if(sa > sb){
                  return 1;
                }else if(sa < sb){
                  return -1;
                }else{
                  return 0;
                }
              }
          );
          break;
      }

      _ordersController.add(_orders);
  }

  void _addOrdersListener() {
    _firestore.collection("loja_virtual_orders").snapshots().listen(
        (snapshot){
          snapshot.documentChanges.forEach(
              (changed){
                String orderId = changed.document.documentID;

                switch(changed.type){
                  case DocumentChangeType.added:
                    _orders.add(changed.document);
                    break;
                  case DocumentChangeType.modified:
                    _orders.removeWhere((order) => order.documentID == orderId);
                    _orders.add(changed.document);
                    break;
                  case DocumentChangeType.removed:
                    _orders.removeWhere((order) => order.documentID == orderId);
                    break;
                }
              }
          );
          _sort();
        }
    );
  }


}