// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'common.dart';

class AnalyzeCommand extends Command<Null> {
  AnalyzeCommand(this.packagesDir);

  final Directory packagesDir;

  @override
  final String name = 'analyze';

  @override
  final String description = 'Analyzes all packages.';

  @override
  Future<Null> run() async {
    print('Activating tuneup package...');
    final ProcessResult activationResult = await Process.run(
        'pub', <String>['global', 'activate', 'tuneup'],
        workingDirectory: packagesDir.path);
    if (activationResult.exitCode != 0) {
      print('ERROR: Unable to activate tuneup package.');
      throw new ToolExit(1);
    }

    await for (Directory package in _listAllPackages(packagesDir)) {
      final int exitCode =
          await runAndStream('flutter', <String>['packages', 'get'], package);
      if (exitCode != 0) {
        print(
            'ERROR: Unable to run "flutter packages get" in package $package.');
        throw new ToolExit(1);
      }
    }

    final List<String> failingPackages = <String>[];
    await for (Directory package in _listAllPluginPackages(packagesDir)) {
      final int exitCode = await runAndStream(
          'pub', <String>['global', 'run', 'tuneup', 'check'], package);
      if (exitCode != 0) {
        failingPackages.add(p.basename(package.path));
      }
    }

    print('\n\n');
    if (failingPackages.isNotEmpty) {
      print('The following packages have analyzer errors (see above):');
      failingPackages.forEach((String package) {
        print(' * $package');
      });
      throw new ToolExit(1);
    }

    print('No analyzer errors found!');
  }

  Stream<Directory> _listAllPluginPackages(Directory root) =>
      root.list().where((FileSystemEntity entity) =>
          entity is Directory &&
          new File(p.join(entity.path, 'pubspec.yaml')).existsSync());

  Stream<Directory> _listAllPackages(Directory root) => root
      .list(recursive: true)
      .where((FileSystemEntity entity) =>
          entity is File && p.basename(entity.path) == 'pubspec.yaml')
      .map((FileSystemEntity entity) => entity.parent);
}
