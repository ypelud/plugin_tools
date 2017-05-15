// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

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
    print('TODO(goderbauer): Implement command when '
        'https://github.com/flutter/flutter/issues/10015 is resolved.');
    throw new ToolExit(1);
  }
}
