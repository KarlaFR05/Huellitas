enum FaseReporte {
  requiereAtencion,
  recibiendoAtencion,
  seEncuentraASalvo;

  String get label {
    switch (this) {
      case FaseReporte.requiereAtencion:
        return 'Requiere atención';
      case FaseReporte.recibiendoAtencion:
        return 'Recibiendo atención';
      case FaseReporte.seEncuentraASalvo:
        return 'Se encuentra a salvo';
    }
  }

  int get id {
    switch (this) {
      case FaseReporte.requiereAtencion:
        return 1;
      case FaseReporte.recibiendoAtencion:
        return 2;
      case FaseReporte.seEncuentraASalvo:
        return 3;
    }
  }

  static FaseReporte fromId(int id) {
    switch (id) {
      case 1:
        return FaseReporte.requiereAtencion;
      case 2:
        return FaseReporte.recibiendoAtencion;
      case 3:
        return FaseReporte.seEncuentraASalvo;
      default:
        return FaseReporte.requiereAtencion;
    }
  }
}