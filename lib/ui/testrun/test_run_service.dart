import 'package:saiive.live/service_locator.dart';
import 'package:saiive.live/ui/testrun/test_run_info.dart';
import 'package:saiive.live/util/sharedprefsutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class ITestInfoService {
  Future showTestInfoPage(BuildContext context);
}

class TestInfoService implements ITestInfoService {
  bool _helpPageDisplayed = false;

  @override
  Future showTestInfoPage(BuildContext context) async {
    var showTestModePage = await sl.get<SharedPrefsUtil>().getShowTestModePage();

    if (showTestModePage && !_helpPageDisplayed) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => TestRunInfoScreen()));
      _helpPageDisplayed = true;
    }
  }
}
