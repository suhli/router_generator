class GenerateRouter {
  /// The name of the page
  final String pageName;

  const GenerateRouter(this.pageName);
}

class GenerateRouterParam {
  /// The key of the param, use the field name instead if not provided
  final String key;

  /// If true, the arguments from route must contains this param
  final bool required;

  const GenerateRouterParam({this.key, this.required = false});
}

/// annotate param field with this when use field'name as key and not required
const routerParam = GenerateRouterParam();

/// The state needs to inject dependencies should annotates with [inject]
const inject = GenerateRouteInject._();

class GenerateRouteInject {
  const GenerateRouteInject._();
}
