class Pagina<T> {
  final List<T> elementos;
  final String? siguienteCursor;
  final bool hayMas;

  const Pagina({
    required this.elementos,
    this.siguienteCursor,
    required this.hayMas,
  });
}
