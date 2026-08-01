enum CategoriaOrganizacion {
  sinFinesLucro,
  refugios,
  gubernamentales;

  String get label {
    switch (this) {
      case CategoriaOrganizacion.sinFinesLucro:
        return 'Organizaciones Sin Fines De Lucro';
      case CategoriaOrganizacion.refugios:
        return 'Refugios';
      case CategoriaOrganizacion.gubernamentales:
        return 'Gubernamentales';
    }
  }
}