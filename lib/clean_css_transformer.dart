// Copyright (c) 2015, the clean_css_transformer project authors. Please see
// the AUTHORS file for details. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Transformer that uses cleancss to minify CSS files.
library clean_css_transformer;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:barback/barback.dart';

/// Transformer Options:
///
/// * [executable] Path to the cleancss executable. DEFAULT: `'cleancss'`
/// * [skip_import] Disable @import processing. DEFAULT: `false`
/// * [skip_rebase] Disable URLs rebasing. DEFAULT: `false`
/// * [skip_advanced] Disable advanced optimizations - selector & property
///   merging, reduction, etc. DEFAULT: `false`
/// * [skip_aggressive_merging] Disable properties merging based on their order. DEFAULT: `false`
/// * [skip_media_merging] Disable @media merging. DEFAULT: `false`
/// * [skip_restructuring] Disable restructuring optimizations. DEFAULT: `false`
/// * [skip_shorthand_compacting] Disable shorthand compacting. DEFAULT: `false`
/// * [source_map] Enables building input's source map. DEFAULT: `false`
class TransformerOptions {
  static const String _defaultExecutable = 'cleancss';

  final String executable;
  final bool skipImport;
  final bool skipRebase;
  final bool skipAdvanced;
  final bool skipAggressiveMerging;
  final bool skipMediaMerging;
  final bool skipRestructuring;
  final bool skipShorthandCompacting;
  final bool sourceMap;

  TransformerOptions(this.executable, this.skipImport, this.skipRebase,
                     this.skipAdvanced, this.skipAggressiveMerging,
                     this.skipMediaMerging, this.skipRestructuring,
                     this.skipShorthandCompacting, this.sourceMap);

  factory TransformerOptions.parse(Map configuration) {
    config(key, defaultValue) {
      var value = configuration[key];
      return value != null ? value : defaultValue;
    }

    return new TransformerOptions(
        config('executable', _defaultExecutable),
        config('skip_import', false),
        config('skip_rebase', false),
        config('skip_advanced', false),
        config('skip_aggressive_merging', false),
        config('skip_media_merging', false),
        config('skip_restructuring', false),
        config('skip_shorthand_compacting', false),
        config('source_map', false));
  }
}

/// Transforms CSS files using cleancss.
class CleanCssTransformer extends Transformer implements DeclaringTransformer {
  final BarbackSettings _settings;
  final TransformerOptions _options;

  CleanCssTransformer.asPlugin(BarbackSettings s)
      : _settings = s,
        _options = new TransformerOptions.parse(s.configuration);

  final String allowedExtensions = '.css';

  Future apply(Transform transform) async {
    final asset = transform.primaryInput;
    if (_settings.mode == BarbackMode.RELEASE) {
      return null;
    }

    final flags = [];
    if (_options.skipImport) flags.add('--skip-import');
    if (_options.skipRebase) flags.add('--skip-rebase');
    if (_options.skipAdvanced) flags.add('--skip-advanced');
    if (_options.skipAggressiveMerging) flags.add('--skip-aggressive-merging');
    if (_options.skipMediaMerging) flags.add('--skip-media-merging');
    if (_options.skipRestructuring) flags.add('--skip-restructuring');
    if (_options.skipShorthandCompacting) flags.add('--skip-shorthand-compacting');
    if (_options.sourceMap) flags.add('--source-map-inline-sources');

    final Process process = await Process.start(_options.executable, flags);
    await process.stdin.addStream(asset.read());
    await process.stdin.close();
    final exitCode = await process.exitCode;
    if (exitCode == 0) {
      transform.addOutput(new Asset.fromStream(asset.id, process.stdout));
    } else {
      final errorString = await process.stderr.transform(UTF8.decoder).fold('', (a, b) => a + b);
      transform.logger.error(errorString, asset: asset.id);
    }
  }

  Future declareOutputs(DeclaringTransform transform) {
    transform.declareOutput(transform.primaryId);
    return new Future.value();
  }
}
