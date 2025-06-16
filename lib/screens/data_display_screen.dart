import 'package:firebaseproject/controllers/tech_guide_controller.dart';
import 'package:firebaseproject/models/tech_guide_response.dart';
import 'package:firebaseproject/models/version_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataDisplayScreen extends StatefulWidget {
  final String profession;
  final String category;
  final String prompt;

  const DataDisplayScreen({
    super.key,
    required this.profession,
    required this.category,
    required this.prompt,
  });

  @override
  State<DataDisplayScreen> createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  // Real-time version data controller
  final RxList<VersionInfo> realTimeVersions = <VersionInfo>[].obs;
  final RxBool isLoadingVersions = false.obs;
  final RxString versionErrorMessage = ''.obs;

  // Expansion states for compact view
  final RxBool isContentExpanded = false.obs;
  final RxBool isVersionsExpanded = false.obs;
  final RxBool isSourcesExpanded = false.obs;
  final RxBool isDocumentationExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchRealTimeVersions();
  }

  // [Keep all existing API methods unchanged]
  Future<void> _fetchRealTimeVersions() async {
    isLoadingVersions.value = true;
    versionErrorMessage.value = '';
    realTimeVersions.clear();

    try {
      final List<VersionInfo> versions = [];

      switch (widget.category.toLowerCase()) {
        case 'javascript':
          versions.addAll(await _fetchJavaScriptVersions());
          break;
        case 'css':
          versions.addAll(await _fetchCSSVersions());
          break;
        case 'html':
          versions.addAll(await _fetchHTMLVersions());
          break;
        case 'frameworks':
          versions.addAll(await _fetchFrameworkVersions());
          break;
        case 'node.js':
        case 'nodejs':
          versions.addAll(await _fetchNodeJSVersions());
          break;
        case 'python':
          versions.addAll(await _fetchPythonVersions());
          break;
        case 'databases':
          versions.addAll(await _fetchDatabaseVersions());
          break;
        case 'tools':
          versions.addAll(await _fetchDevelopmentToolVersions());
          break;
        default:
          versions.addAll(await _fetchGeneralVersions());
      }

      realTimeVersions.assignAll(versions);
    } catch (e) {
      versionErrorMessage.value = 'Failed to fetch real-time version data: $e';
      print('Error fetching versions: $e');
    } finally {
      isLoadingVersions.value = false;
    }
  }

  Future<List<VersionInfo>> _fetchJavaScriptVersions() async {
    final List<VersionInfo> versions = [];

    try {
      final nodeResponse = await http.get(
        Uri.parse('https://nodejs.org/dist/index.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (nodeResponse.statusCode == 200) {
        final nodeData = jsonDecode(nodeResponse.body) as List;
        if (nodeData.isNotEmpty) {
          final latestNode = nodeData.first;
          versions.add(VersionInfo(
            technology: 'Node.js',
            version: latestNode['version']?.toString().replaceFirst('v', '') ??
                'Unknown',
            releaseDate: latestNode['date']?.toString() ?? '',
            additionalInfo: 'LTS: ${latestNode['lts'] ?? 'No'}',
          ));
        }
      }

      final npmResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/npm/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (npmResponse.statusCode == 200) {
        final npmData = jsonDecode(npmResponse.body);
        versions.add(VersionInfo(
          technology: 'npm',
          version: npmData['version']?.toString() ?? 'Unknown',
          releaseDate: npmData['time']?[npmData['version']]?.toString() ?? '',
          additionalInfo: 'Package Manager',
        ));
      }

      final tsResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/typescript/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (tsResponse.statusCode == 200) {
        final tsData = jsonDecode(tsResponse.body);
        versions.add(VersionInfo(
          technology: 'TypeScript',
          version: tsData['version']?.toString() ?? 'Unknown',
          releaseDate: tsData['time']?[tsData['version']]?.toString() ?? '',
          additionalInfo: 'Superset of JavaScript',
        ));
      }
    } catch (e) {
      print('Error fetching JavaScript versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchFrameworkVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // React
      final reactResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/react/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (reactResponse.statusCode == 200) {
        final reactData = jsonDecode(reactResponse.body);
        versions.add(VersionInfo(
          technology: 'React',
          version: reactData['version']?.toString() ?? 'Unknown',
          releaseDate:
              reactData['time']?[reactData['version']]?.toString() ?? '',
          additionalInfo: 'UI Library',
        ));
      }

      // Vue.js
      final vueResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/vue/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (vueResponse.statusCode == 200) {
        final vueData = jsonDecode(vueResponse.body);
        versions.add(VersionInfo(
          technology: 'Vue.js',
          version: vueData['version']?.toString() ?? 'Unknown',
          releaseDate: vueData['time']?[vueData['version']]?.toString() ?? '',
          additionalInfo: 'Progressive Framework',
        ));
      }

      // Angular CLI
      final angularResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/@angular/cli/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (angularResponse.statusCode == 200) {
        final angularData = jsonDecode(angularResponse.body);
        versions.add(VersionInfo(
          technology: 'Angular CLI',
          version: angularData['version']?.toString() ?? 'Unknown',
          releaseDate:
              angularData['time']?[angularData['version']]?.toString() ?? '',
          additionalInfo: 'Development Platform',
        ));
      }

      // Next.js
      final nextResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/next/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (nextResponse.statusCode == 200) {
        final nextData = jsonDecode(nextResponse.body);
        versions.add(VersionInfo(
          technology: 'Next.js',
          version: nextData['version']?.toString() ?? 'Unknown',
          releaseDate: nextData['time']?[nextData['version']]?.toString() ?? '',
          additionalInfo: 'React Framework',
        ));
      }
    } catch (e) {
      print('Error fetching framework versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchNodeJSVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Node.js (reuse from JavaScript method)
      final nodeResponse = await http.get(
        Uri.parse('https://nodejs.org/dist/index.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (nodeResponse.statusCode == 200) {
        final nodeData = jsonDecode(nodeResponse.body) as List;
        if (nodeData.isNotEmpty) {
          final latestNode = nodeData.first;
          versions.add(VersionInfo(
            technology: 'Node.js',
            version: latestNode['version']?.toString().replaceFirst('v', '') ??
                'Unknown',
            releaseDate: latestNode['date']?.toString() ?? '',
            additionalInfo: 'LTS: ${latestNode['lts'] ?? 'No'}',
          ));
        }
      }

      // Express.js
      final expressResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/express/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (expressResponse.statusCode == 200) {
        final expressData = jsonDecode(expressResponse.body);
        versions.add(VersionInfo(
          technology: 'Express.js',
          version: expressData['version']?.toString() ?? 'Unknown',
          releaseDate:
              expressData['time']?[expressData['version']]?.toString() ?? '',
          additionalInfo: 'Web Framework',
        ));
      }

      // Fastify
      final fastifyResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/fastify/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (fastifyResponse.statusCode == 200) {
        final fastifyData = jsonDecode(fastifyResponse.body);
        versions.add(VersionInfo(
          technology: 'Fastify',
          version: fastifyData['version']?.toString() ?? 'Unknown',
          releaseDate:
              fastifyData['time']?[fastifyData['version']]?.toString() ?? '',
          additionalInfo: 'Fast Web Framework',
        ));
      }

      // Nest.js
      final nestResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/@nestjs/core/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (nestResponse.statusCode == 200) {
        final nestData = jsonDecode(nestResponse.body);
        versions.add(VersionInfo(
          technology: 'NestJS',
          version: nestData['version']?.toString() ?? 'Unknown',
          releaseDate: nestData['time']?[nestData['version']]?.toString() ?? '',
          additionalInfo: 'Progressive Framework',
        ));
      }
    } catch (e) {
      print('Error fetching Node.js versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchPythonVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Django
      final djangoResponse = await http.get(
        Uri.parse('https://pypi.org/pypi/django/json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (djangoResponse.statusCode == 200) {
        final djangoData = jsonDecode(djangoResponse.body);
        final version = djangoData['info']?['version']?.toString() ?? 'Unknown';
        versions.add(VersionInfo(
          technology: 'Django',
          version: version,
          releaseDate: '',
          additionalInfo: 'Web Framework',
        ));
      }

      // Flask
      final flaskResponse = await http.get(
        Uri.parse('https://pypi.org/pypi/flask/json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (flaskResponse.statusCode == 200) {
        final flaskData = jsonDecode(flaskResponse.body);
        final version = flaskData['info']?['version']?.toString() ?? 'Unknown';
        versions.add(VersionInfo(
          technology: 'Flask',
          version: version,
          releaseDate: '',
          additionalInfo: 'Micro Framework',
        ));
      }

      // FastAPI
      final fastapiResponse = await http.get(
        Uri.parse('https://pypi.org/pypi/fastapi/json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (fastapiResponse.statusCode == 200) {
        final fastapiData = jsonDecode(fastapiResponse.body);
        final version =
            fastapiData['info']?['version']?.toString() ?? 'Unknown';
        versions.add(VersionInfo(
          technology: 'FastAPI',
          version: version,
          releaseDate: '',
          additionalInfo: 'Modern API Framework',
        ));
      }

      // Pandas
      final pandasResponse = await http.get(
        Uri.parse('https://pypi.org/pypi/pandas/json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (pandasResponse.statusCode == 200) {
        final pandasData = jsonDecode(pandasResponse.body);
        final version = pandasData['info']?['version']?.toString() ?? 'Unknown';
        versions.add(VersionInfo(
          technology: 'Pandas',
          version: version,
          releaseDate: '',
          additionalInfo: 'Data Analysis',
        ));
      }

      // NumPy
      final numpyResponse = await http.get(
        Uri.parse('https://pypi.org/pypi/numpy/json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (numpyResponse.statusCode == 200) {
        final numpyData = jsonDecode(numpyResponse.body);
        final version = numpyData['info']?['version']?.toString() ?? 'Unknown';
        versions.add(VersionInfo(
          technology: 'NumPy',
          version: version,
          releaseDate: '',
          additionalInfo: 'Scientific Computing',
        ));
      }
    } catch (e) {
      print('Error fetching Python versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchDatabaseVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // MongoDB (via npm driver)
      final mongoResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/mongodb/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (mongoResponse.statusCode == 200) {
        final mongoData = jsonDecode(mongoResponse.body);
        versions.add(VersionInfo(
          technology: 'MongoDB Driver',
          version: mongoData['version']?.toString() ?? 'Unknown',
          releaseDate:
              mongoData['time']?[mongoData['version']]?.toString() ?? '',
          additionalInfo: 'NoSQL Database',
        ));
      }

      // Mongoose
      final mongooseResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/mongoose/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (mongooseResponse.statusCode == 200) {
        final mongooseData = jsonDecode(mongooseResponse.body);
        versions.add(VersionInfo(
          technology: 'Mongoose',
          version: mongooseData['version']?.toString() ?? 'Unknown',
          releaseDate:
              mongooseData['time']?[mongooseData['version']]?.toString() ?? '',
          additionalInfo: 'MongoDB ODM',
        ));
      }

      // Prisma
      final prismaResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/prisma/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (prismaResponse.statusCode == 200) {
        final prismaData = jsonDecode(prismaResponse.body);
        versions.add(VersionInfo(
          technology: 'Prisma',
          version: prismaData['version']?.toString() ?? 'Unknown',
          releaseDate:
              prismaData['time']?[prismaData['version']]?.toString() ?? '',
          additionalInfo: 'Database Toolkit',
        ));
      }

      // Sequelize
      final sequelizeResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/sequelize/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (sequelizeResponse.statusCode == 200) {
        final sequelizeData = jsonDecode(sequelizeResponse.body);
        versions.add(VersionInfo(
          technology: 'Sequelize',
          version: sequelizeData['version']?.toString() ?? 'Unknown',
          releaseDate:
              sequelizeData['time']?[sequelizeData['version']]?.toString() ??
                  '',
          additionalInfo: 'SQL ORM',
        ));
      }
    } catch (e) {
      print('Error fetching database versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchDevelopmentToolVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Webpack
      final webpackResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/webpack/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (webpackResponse.statusCode == 200) {
        final webpackData = jsonDecode(webpackResponse.body);
        versions.add(VersionInfo(
          technology: 'Webpack',
          version: webpackData['version']?.toString() ?? 'Unknown',
          releaseDate:
              webpackData['time']?[webpackData['version']]?.toString() ?? '',
          additionalInfo: 'Module Bundler',
        ));
      }

      // Vite
      final viteResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/vite/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (viteResponse.statusCode == 200) {
        final viteData = jsonDecode(viteResponse.body);
        versions.add(VersionInfo(
          technology: 'Vite',
          version: viteData['version']?.toString() ?? 'Unknown',
          releaseDate: viteData['time']?[viteData['version']]?.toString() ?? '',
          additionalInfo: 'Build Tool',
        ));
      }

      // ESLint
      final eslintResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/eslint/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (eslintResponse.statusCode == 200) {
        final eslintData = jsonDecode(eslintResponse.body);
        versions.add(VersionInfo(
          technology: 'ESLint',
          version: eslintData['version']?.toString() ?? 'Unknown',
          releaseDate:
              eslintData['time']?[eslintData['version']]?.toString() ?? '',
          additionalInfo: 'JavaScript Linter',
        ));
      }

      // Prettier
      final prettierResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/prettier/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (prettierResponse.statusCode == 200) {
        final prettierData = jsonDecode(prettierResponse.body);
        versions.add(VersionInfo(
          technology: 'Prettier',
          version: prettierData['version']?.toString() ?? 'Unknown',
          releaseDate:
              prettierData['time']?[prettierData['version']]?.toString() ?? '',
          additionalInfo: 'Code Formatter',
        ));
      }

      // Babel
      final babelResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/@babel/core/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (babelResponse.statusCode == 200) {
        final babelData = jsonDecode(babelResponse.body);
        versions.add(VersionInfo(
          technology: 'Babel',
          version: babelData['version']?.toString() ?? 'Unknown',
          releaseDate:
              babelData['time']?[babelData['version']]?.toString() ?? '',
          additionalInfo: 'JavaScript Compiler',
        ));
      }
    } catch (e) {
      print('Error fetching development tool versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchCSSVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Sass
      final sassResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/sass/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (sassResponse.statusCode == 200) {
        final sassData = jsonDecode(sassResponse.body);
        versions.add(VersionInfo(
          technology: 'Sass',
          version: sassData['version']?.toString() ?? 'Unknown',
          releaseDate: sassData['time']?[sassData['version']]?.toString() ?? '',
          additionalInfo: 'CSS Preprocessor',
        ));
      }

      // Tailwind CSS
      final tailwindResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/tailwindcss/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (tailwindResponse.statusCode == 200) {
        final tailwindData = jsonDecode(tailwindResponse.body);
        versions.add(VersionInfo(
          technology: 'Tailwind CSS',
          version: tailwindData['version']?.toString() ?? 'Unknown',
          releaseDate:
              tailwindData['time']?[tailwindData['version']]?.toString() ?? '',
          additionalInfo: 'Utility-First CSS',
        ));
      }

      // PostCSS
      final postcssResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/postcss/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (postcssResponse.statusCode == 200) {
        final postcssData = jsonDecode(postcssResponse.body);
        versions.add(VersionInfo(
          technology: 'PostCSS',
          version: postcssData['version']?.toString() ?? 'Unknown',
          releaseDate:
              postcssData['time']?[postcssData['version']]?.toString() ?? '',
          additionalInfo: 'CSS Tool',
        ));
      }

      // Bootstrap
      final bootstrapResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/bootstrap/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (bootstrapResponse.statusCode == 200) {
        final bootstrapData = jsonDecode(bootstrapResponse.body);
        versions.add(VersionInfo(
          technology: 'Bootstrap',
          version: bootstrapData['version']?.toString() ?? 'Unknown',
          releaseDate:
              bootstrapData['time']?[bootstrapData['version']]?.toString() ??
                  '',
          additionalInfo: 'CSS Framework',
        ));
      }
    } catch (e) {
      print('Error fetching CSS versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchHTMLVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // Add HTML5 standard info (static since it's a web standard)
      versions.add(VersionInfo(
        technology: 'HTML5',
        version: '5.2',
        releaseDate: '2017-12-14',
        additionalInfo: 'W3C Recommendation',
      ));

      // HTML Webpack Plugin
      final htmlWebpackResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/html-webpack-plugin/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (htmlWebpackResponse.statusCode == 200) {
        final htmlWebpackData = jsonDecode(htmlWebpackResponse.body);
        versions.add(VersionInfo(
          technology: 'HTML Webpack Plugin',
          version: htmlWebpackData['version']?.toString() ?? 'Unknown',
          releaseDate: htmlWebpackData['time']?[htmlWebpackData['version']]
                  ?.toString() ??
              '',
          additionalInfo: 'HTML Generation',
        ));
      }

      // html-minifier
      final htmlMinifierResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/html-minifier/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (htmlMinifierResponse.statusCode == 200) {
        final htmlMinifierData = jsonDecode(htmlMinifierResponse.body);
        versions.add(VersionInfo(
          technology: 'HTML Minifier',
          version: htmlMinifierData['version']?.toString() ?? 'Unknown',
          releaseDate: htmlMinifierData['time']?[htmlMinifierData['version']]
                  ?.toString() ??
              '',
          additionalInfo: 'HTML Optimization',
        ));
      }

      // Pug (formerly Jade)
      final pugResponse = await http.get(
        Uri.parse('https://registry.npmjs.org/pug/latest'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (pugResponse.statusCode == 200) {
        final pugData = jsonDecode(pugResponse.body);
        versions.add(VersionInfo(
          technology: 'Pug',
          version: pugData['version']?.toString() ?? 'Unknown',
          releaseDate: pugData['time']?[pugData['version']]?.toString() ?? '',
          additionalInfo: 'Template Engine',
        ));
      }
    } catch (e) {
      print('Error fetching HTML versions: $e');
    }

    return versions;
  }

  Future<List<VersionInfo>> _fetchGeneralVersions() async {
    final List<VersionInfo> versions = [];

    try {
      // For UI/UX Designer categories
      if (widget.profession.toLowerCase().contains('designer')) {
        // Add design-related static versions
        versions.addAll([
          VersionInfo(
            technology: 'Figma',
            version: 'Web App',
            releaseDate: '2024-12-01',
            additionalInfo: 'Design Tool',
          ),
          VersionInfo(
            technology: 'Adobe XD',
            version: '57.1',
            releaseDate: '2024-11-15',
            additionalInfo: 'Design Platform',
          ),
          VersionInfo(
            technology: 'Sketch',
            version: '99.1',
            releaseDate: '2024-12-05',
            additionalInfo: 'Design Tool',
          ),
        ]);
      }

      // For Data Scientist categories
      if (widget.profession.toLowerCase().contains('data')) {
        // Jupyter
        final jupyterResponse = await http.get(
          Uri.parse('https://pypi.org/pypi/jupyter/json'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        if (jupyterResponse.statusCode == 200) {
          final jupyterData = jsonDecode(jupyterResponse.body);
          final version =
              jupyterData['info']?['version']?.toString() ?? 'Unknown';
          versions.add(VersionInfo(
            technology: 'Jupyter',
            version: version,
            releaseDate: '',
            additionalInfo: 'Interactive Computing',
          ));
        }

        // TensorFlow
        final tensorflowResponse = await http.get(
          Uri.parse('https://pypi.org/pypi/tensorflow/json'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        if (tensorflowResponse.statusCode == 200) {
          final tensorflowData = jsonDecode(tensorflowResponse.body);
          final version =
              tensorflowData['info']?['version']?.toString() ?? 'Unknown';
          versions.add(VersionInfo(
            technology: 'TensorFlow',
            version: version,
            releaseDate: '',
            additionalInfo: 'Machine Learning',
          ));
        }

        // Scikit-learn
        final sklearnResponse = await http.get(
          Uri.parse('https://pypi.org/pypi/scikit-learn/json'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        if (sklearnResponse.statusCode == 200) {
          final sklearnData = jsonDecode(sklearnResponse.body);
          final version =
              sklearnData['info']?['version']?.toString() ?? 'Unknown';
          versions.add(VersionInfo(
            technology: 'Scikit-learn',
            version: version,
            releaseDate: '',
            additionalInfo: 'Machine Learning Library',
          ));
        }
      }

      // If no specific versions found, add some general tech versions
      if (versions.isEmpty) {
        // Git (static - command line tool)
        versions.add(VersionInfo(
          technology: 'Git',
          version: '2.43.0',
          releaseDate: '2023-11-20',
          additionalInfo: 'Version Control',
        ));

        // VS Code (static - general editor)
        versions.add(VersionInfo(
          technology: 'VS Code',
          version: '1.85.0',
          releaseDate: '2024-01-03',
          additionalInfo: 'Code Editor',
        ));
      }
    } catch (e) {
      print('Error fetching general versions: $e');
    }

    return versions;
  }

  String _capitalizeString(String text) {
    if (text.isEmpty) return text;
    return "${text[0].toUpperCase()}${text.substring(1)}";
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.split('T').first;
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      Get.snackbar(
        'Error',
        'No URL provided',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open link: $url',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _cleanContent(String text) {
    return text
        .replaceAll(RegExp(r'\*{2,}'), '')
        .replaceAll(RegExp(r'_{2,}'), '')
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        .replaceAllMapped(RegExp(r'`([^`]*)`'), (match) => match.group(1) ?? '')
        .replaceAllMapped(
            RegExp(r'\*([^*]*)\*'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'_([^_]*)_'), (match) => match.group(1) ?? '')
        .replaceAllMapped(
            RegExp(r'\*\*([^*]*)\*\*'), (match) => match.group(1) ?? '')
        .replaceAllMapped(
            RegExp(r'__([^_]*)__'), (match) => match.group(1) ?? '')
        .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
        .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n')
        .trim();
  }

  String _cleanName(String name) {
    return name
        .replaceAll(RegExp(r'[*_~`#\[\]{}|\\]'), '')
        .replaceAll(RegExp(r'[^\w\s.,!?;:()\-&]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _getPreviewText(String fullText, {int maxLength = 200}) {
    if (fullText.length <= maxLength) return fullText;

    String preview = fullText.substring(0, maxLength);
    int lastSentence = preview.lastIndexOf('.');
    if (lastSentence > maxLength * 0.5) {
      preview = preview.substring(0, lastSentence + 1);
    } else {
      int lastSpace = preview.lastIndexOf(' ');
      if (lastSpace > 0) {
        preview = preview.substring(0, lastSpace) + '...';
      }
    }
    return preview;
  }

  @override
  Widget build(BuildContext context) {
    final techGuideController = Get.find<TechGuideController>();
    techGuideController.fetchTechGuideData(widget.category, widget.prompt);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profession} - ${widget.category}'),
        backgroundColor: Colors.deepPurple.shade50,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh All Data',
            onPressed: () {
              _fetchRealTimeVersions();
              techGuideController.fetchTechGuideData(
                  widget.category, widget.prompt);
              Get.snackbar(
                'Refreshing',
                'Fetching latest information...',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _copyToClipboard(techGuideController),
          ),
        ],
      ),
      body: Obx(() {
        if (techGuideController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Loading information about ${widget.category}...',
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic),
                ),
                if (isLoadingVersions.value) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Fetching real-time version data...',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          );
        }

        if (techGuideController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Error: ${techGuideController.errorMessage.value}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    techGuideController.fetchTechGuideData(
                        widget.category, widget.prompt);
                    _fetchRealTimeVersions();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (techGuideController.response.value != null) {
          final TechGuideResponse response =
              techGuideController.response.value!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COMPACT MAIN CONTENT SECTION
                _buildCompactContentSection(response),
                const SizedBox(height: 16),

                // NEW: COMPACT VERSIONS TABLE SECTION
                _buildCompactVersionsTableSection(),
                const SizedBox(height: 16),

                // COMPACT SOURCES SECTION
                _buildCompactSourcesSection(response),
                const SizedBox(height: 16),

                // COMPACT DOCUMENTATION SECTION
                if (response.documentationLinks.isNotEmpty)
                  _buildCompactDocumentationSection(response),

                const SizedBox(height: 24),
                _buildFeedbackSection(),
                const SizedBox(height: 100),
              ],
            ),
          );
        }

        return const Center(child: Text('No data available.'));
      }),
    );
  }

  // MAIN CONTENT SECTION (unchanged)
  Widget _buildCompactContentSection(TechGuideResponse response) {
    final fullContent = _cleanContent(response.mainContent);
    final previewContent = _getPreviewText(fullContent);
    final hasMore = fullContent.length > previewContent.length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade100,
                    Colors.deepPurple.shade50
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.deepPurple.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'About ${widget.category} in ${widget.profession}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final showFull = isContentExpanded.value;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      showFull ? fullContent : previewContent,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    if (hasMore) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => isContentExpanded.toggle(),
                          icon: Icon(
                            showFull ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                          ),
                          label: Text(showFull ? 'See Less' : 'See More'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurple.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // NEW: BUILD COMPACT VERSIONS TABLE SECTION
  Widget _buildCompactVersionsTableSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HIGHLIGHTED SUBHEADING
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.system_update,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Latest Versions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => isLoadingVersions.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: _fetchRealTimeVersions,
                          icon: Icon(Icons.refresh,
                              size: 16, color: Colors.orange.shade600),
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: const EdgeInsets.all(4),
                          tooltip: 'Refresh Version Data',
                        )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (versionErrorMessage.value.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          versionErrorMessage.value,
                          style: TextStyle(
                              color: Colors.red.shade600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final versions = realTimeVersions.where((version) {
                return version.version.isNotEmpty &&
                    version.technology.isNotEmpty;
              }).toList();

              if (versions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.grey.shade400, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        'No version information available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Real-time version data could not be fetched for ${widget.category}',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchRealTimeVersions,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final showExpanded = isVersionsExpanded.value;
              final displayVersions =
                  showExpanded ? versions : versions.take(3).toList();

              return Column(
                children: [
                  // TABLE CONTAINER
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // TABLE HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  '#',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Technology',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Version',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Released',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // TABLE ROWS
                        ...displayVersions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final version = entry.value;
                          final isEven = index % 2 == 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color:
                                  isEven ? Colors.white : Colors.grey.shade50,
                              border: Border(
                                bottom: index < displayVersions.length - 1
                                    ? BorderSide(
                                        color: Colors.grey.shade200, width: 0.5)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Row(
                              children: [
                                // ROW NUMBER
                                Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // TECHNOLOGY NAME & INFO
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _cleanName(version.technology),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (version
                                          .additionalInfo.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          version.additionalInfo,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // VERSION
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 0.5),
                                    ),
                                    child: Text(
                                      version.version,
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // RELEASE DATE
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    version.releaseDate.isNotEmpty
                                        ? _formatDate(version.releaseDate)
                                        : 'Unknown',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'monospace',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  // EXPAND/COLLAPSE BUTTON
                  if (versions.length > 3) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => isVersionsExpanded.toggle(),
                        icon: Icon(
                          showExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          showExpanded
                              ? 'Show Less'
                              : 'Show ${versions.length - 3} More',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // SOURCES SECTION (unchanged)
  Widget _buildCompactSourcesSection(TechGuideResponse response) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Sources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  if (response.sources.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'AI Generated',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final sources = response.sources.where((source) {
                if (source == null) return false;
                final name = source.name?.toString().trim() ?? '';
                return name.isNotEmpty &&
                    name.replaceAll(RegExp(r'[^\w\s]'), '').trim().isNotEmpty;
              }).toList();

              final showExpanded = isSourcesExpanded.value;
              final displaySources =
                  showExpanded ? sources : sources.take(3).toList();

              if (sources.isEmpty) {
                return _buildCompactEmptyState(
                  icon: Icons.library_books_outlined,
                  title: 'No External Sources',
                  subtitle: 'Information generated using AI knowledge',
                  actionText: 'Suggest Sources',
                  onAction: _showSourceSuggestionDialog,
                );
              }

              return Column(
                children: [
                  ...displaySources.asMap().entries.map((entry) {
                    final index = entry.key;
                    final source = entry.value;
                    return _buildCompactSourceItem(index, source);
                  }).toList(),
                  if (sources.length > 3) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => isSourcesExpanded.toggle(),
                        icon: Icon(
                          showExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          showExpanded
                              ? 'Show Less'
                              : 'Show ${sources.length - 3} More',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // DOCUMENTATION SECTION (unchanged)
  Widget _buildCompactDocumentationSection(TechGuideResponse response) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade50],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Documentation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final docs = response.documentationLinks;
              final showExpanded = isDocumentationExpanded.value;
              final displayDocs = showExpanded ? docs : docs.take(3).toList();

              return Column(
                children: [
                  ...displayDocs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final doc = entry.value;
                    return _buildCompactSourceItem(index, doc,
                        isDocumentation: true);
                  }).toList(),
                  if (docs.length > 3) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => isDocumentationExpanded.toggle(),
                        icon: Icon(
                          showExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          showExpanded
                              ? 'Show Less'
                              : 'Show ${docs.length - 3} More',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // BUILD COMPACT SOURCE ITEM (unchanged)
  Widget _buildCompactSourceItem(int index, dynamic source,
      {bool isDocumentation = false}) {
    final sourceName = _cleanName(source.name?.toString() ?? 'Unknown Source');
    final sourceUrl = source.url?.toString().trim() ?? '';
    final color = isDocumentation ? Colors.green : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.shade700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            isDocumentation ? Icons.menu_book : Icons.link,
            size: 16,
            color: color.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sourceName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          sourceUrl.isNotEmpty
              ? ElevatedButton.icon(
                  onPressed: () => _launchUrl(sourceUrl),
                  icon: const Icon(Icons.open_in_new, size: 12),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.shade100,
                    foregroundColor: color.shade800,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 28),
                    textStyle: const TextStyle(fontSize: 10),
                    elevation: 1,
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: () {
                    final searchQuery =
                        '$sourceName ${widget.category} ${widget.profession}';
                    _launchUrl(
                        'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}');
                  },
                  icon: const Icon(Icons.search, size: 12),
                  label: const Text('Search'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color.shade700,
                    side: BorderSide(color: color.shade300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 28),
                    textStyle: const TextStyle(fontSize: 10),
                  ),
                ),
        ],
      ),
    );
  }

  // BUILD COMPACT EMPTY STATE
  Widget _buildCompactEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.search, size: 16),
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // COPY TO CLIPBOARD
  void _copyToClipboard(TechGuideController controller) {
    if (controller.response.value != null) {
      final content = _cleanContent(controller.response.value!.mainContent);
      Clipboard.setData(ClipboardData(text: content));
      Get.snackbar(
        'Copied',
        'Content copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // BUILD FEEDBACK SECTION
  Widget _buildFeedbackSection() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade100, Colors.purple.shade50],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.feedback, color: Colors.purple.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Was this helpful?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined,
                            color: Colors.green),
                        onPressed: () {
                          Get.snackbar(
                            'Thank You!',
                            'We appreciate your feedback',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: const EdgeInsets.all(4),
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_down_alt_outlined,
                            color: Colors.red),
                        onPressed: _showFeedbackDialog,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showFollowUpDialog,
                icon: const Icon(Icons.question_answer, size: 16),
                label: const Text('Ask a Follow-up Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SHOW FOLLOW-UP QUESTION DIALOG
  void _showFollowUpDialog() {
    final TextEditingController questionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ask a Follow-up Question'),
        content: TextField(
          controller: questionController,
          decoration: const InputDecoration(
            hintText: 'Type your question here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final question = questionController.text.trim();
              if (question.isNotEmpty) {
                Get.back();
                Get.to(() => DataDisplayScreen(
                      profession: widget.profession,
                      category: widget.category,
                      prompt: question,
                    ));
              }
            },
            child: const Text('Ask'),
          ),
        ],
      ),
    );
  }

  // SHOW FEEDBACK DIALOG
  void _showFeedbackDialog() {
    final List<String> feedbackOptions = [
      'Information is not accurate',
      'Not enough details',
      'Too much information',
      'Missing sources',
      'Version data is outdated',
      'Other issues',
    ];

    final List<bool> selectedOptions =
        List.filled(feedbackOptions.length, false);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('What could we improve?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: feedbackOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;

              return CheckboxListTile(
                title: Text(option),
                value: selectedOptions[index],
                onChanged: (value) {
                  setState(() {
                    selectedOptions[index] = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Feedback Submitted',
                  'Thank you for helping us improve!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // SHOW SOURCE SUGGESTION DIALOG
  void _showSourceSuggestionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Find Reliable Sources'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To find authoritative sources for this topic, try:'),
            const SizedBox(height: 12),
            _buildSuggestionItem(
              Icons.school,
              'Official Documentation',
              'Search for official docs from ${widget.category} creators',
            ),
            const SizedBox(height: 8),
            _buildSuggestionItem(
              Icons.article,
              'Research Papers',
              'Look for academic papers on Google Scholar',
            ),
            const SizedBox(height: 8),
            _buildSuggestionItem(
              Icons.business,
              'Industry Reports',
              'Check industry blogs and tech company publications',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _launchUrl(
                  'https://scholar.google.com/scholar?q=${widget.category}+${widget.profession}');
            },
            child: const Text('Search Scholar'),
          ),
        ],
      ),
    );
  }

  // BUILD SUGGESTION ITEM
  Widget _buildSuggestionItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16, color: Colors.blue.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
