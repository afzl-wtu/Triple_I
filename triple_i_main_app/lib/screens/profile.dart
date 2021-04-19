import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main/widgets/backgroundGrad.dart';

import '../bloc/profile.dart';
import '../helpers/color_helper.dart';
import './components/profile/screen.dart';
import '../widgets/empty_screen.dart';
import '../widgets/loading_indicator.dart';

class Profile extends StatelessWidget {
  final String symbol;

  Profile({
    @required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
      if (state is ProfileLoadingError) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(65, 190, 186, 1),
              title: Text(':('),
            ),
            backgroundColor: Colors.black,
            body: Center(child: EmptyScreen(message: state.error)));
      }

      if (state is ProfileLoaded) {
        return ProfileScreen(
            isSaved: state.isSymbolSaved,
            profile: state.profileModel,
            color: determineColorBasedOnChange(
                state.profileModel.stockProfile.changes));
      }

      return Scaffold(
          body: Stack(children: [
        BackgroundImage(),
        Center(child: LoadingIndicatorWidget())
      ]));
    });
  }
}
