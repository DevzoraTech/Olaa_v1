import 'package:flutter/material.dart';

class UniversotySelectionModel extends ChangeNotifier {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  void initState(BuildContext context) {
    textController ??= TextEditingController();
    textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    super.dispose();
  }
}
