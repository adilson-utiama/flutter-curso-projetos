class ProductValidator {

  String validateImages(List images){
    if(images.isEmpty){
      return "Adicione pelo menos 1 imagem do Produto";
    }else{
      return null;
    }
  }

  String validateTitle(String text){
    if(text.isEmpty){
      return "Preencha o titulo do Produto";
    }else{
      return null;
    }
  }

  String validateDescription(String text){
    if(text.isEmpty){
      return "Preencha a descrição do Produto";
    }else{
      return null;
    }
  }

  String validatePrice(String text){
    double price = double.tryParse(text);
    if(price != null){
      if(!text.contains(".") || text.split(".")[1].length != 2){
        return "Utilize 2 casa decimais";
      }
    }else{
      return "Formato de valor invalido.";
    }
    return null;
  }


  String validateSizes(List sizes){
    if(sizes.isEmpty){
      return "Adicione pelo menos um Tamanho";
    }else{
      return null;
    }
  }


}