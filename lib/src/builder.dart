import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';
import 'generators.dart';

const ROUTER_EXTENSION = '.router';
const _OUTPUT_EXTENSIONS = '.router_table.dart';

const pageRegExpLiteral = r'[A-Za-z_\d-]+';

Builder injectBuilder(BuilderOptions options) =>
    LibraryBuilder(InjectGenerator(), generatedExtension: '.inject.dart');

Builder routerBuilder(BuilderOptions options) {
  return LibraryBuilder(RouterGenerator(),
      header:"",
      generatedExtension: ROUTER_EXTENSION);
}

const routerChecker = TypeChecker.fromRuntime(GenerateRouter);

Builder routerCombiningBuilder(BuilderOptions options) {
  print(options.config['router_table_root_file']);
  return options.config.containsKey('router_table_root_file')
      ? RouterCombiningBuilder(
      router_table_root_file: options.config['router_table_root_file'])
      : RouterCombiningBuilder();
}

class RouterCombiningBuilder implements Builder {
  final String router_table_root_file;

  const RouterCombiningBuilder({this.router_table_root_file = 'main.dart'});

  @override
  Map<String, List<String>> get buildExtensions =>
      const {
        '.dart': [_OUTPUT_EXTENSIONS],
      };

  @override
  Future build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.endsWith(router_table_root_file)) return;
    final pattern = 'lib/**$ROUTER_EXTENSION';
    final assetIds = await buildStep.findAssets(Glob(pattern)).toList()
      ..sort();

    var imports = [];
    var pages = [];
    for (var id in assetIds) {
      var content = (await buildStep.readAsString(id)).trim();
      var lines = content.split('\n').skip(4);
      for(var line in lines){
        if(line.trim().isEmpty){
          continue;
        }
        var args = line.substring(2).split('|');
        imports.add(args[0].trim());
        pages.add('GeneratedPage("${args[1].trim()}",()=>${args[2].trim()}())');
      }
    }

    final output = '''
$defaultFileHeader
import 'package:flutter/widgets.dart';
${imports.join('\n')}
typedef Widget GetPageFunction();

class GeneratedPage{
  final String name;
  final GetPageFunction getPage;
  GeneratedPage(this.name,this.getPage);
}
final PAGES = $pages;
''';
    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(_OUTPUT_EXTENSIONS), output);
  }
}
