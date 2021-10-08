// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom [BlocObserver] which observes all bloc and cubit instances.
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('SimpleBlocObserver.onError got the following error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  runApp(App());
}

/// A [StatelessWidget] which uses:
/// * [bloc](https://pub.dev/packages/bloc)
/// * [flutter_bloc](https://pub.dev/packages/flutter_bloc)
/// to manage the state of a counter.
class App extends StatelessWidget {
  App() {
    Bloc.observer = SimpleBlocObserver();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ExampleBloc(),
        child: CounterPage(),
      ),
    );
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [ExampleBloc].
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: BlocBuilder<ExampleBloc, ExampleState>(
          builder: (context, state) {
            return Center(
              child: Column(children: [
                TextButton(
                    onPressed: () => throw Exception(
                        'Exception directly from TextButton.onPressed'),
                    child: const Text(
                        'Throw exception in onPressed of button (not inside bloc)')),
                TextButton(
                  onPressed: () => BlocProvider.of<ExampleBloc>(context)
                      .add(LoadDataEvent(shouldFail: false)),
                  child:
                      const Text('Load data and succeed (no exception thrown)'),
                ),
                TextButton(
                  onPressed: () => BlocProvider.of<ExampleBloc>(context)
                      .add(LoadDataEvent(shouldFail: true)),
                  child: const Text(
                      'Load data and fail (exception thrown in bloc)'),
                ),
                const Text('--------------'),
                Text('State: $state \nDescription: ${state.description}'),
                if (state is LoadInProgressState)
                  const AnimatedLoadingWidget()
                else if (state is LoadSuccessState)
                  const StaticSuccessWidget()
                else if (state is LoadFailureState)
                  const AnimatedFailureWidget()
              ]),
            );
          },
        ),
      ),
    );
  }
}

abstract class ExampleEvent {}

class LoadDataEvent extends ExampleEvent {
  LoadDataEvent({required this.shouldFail});

  final bool shouldFail;
}

class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  ExampleBloc() : super(const InitialState()) {
    on<LoadDataEvent>(onLoadData);
  }
}

Future<void> onLoadData(
  LoadDataEvent event,
  Emitter<ExampleState> emit,
) async {
  emit(const LoadInProgressState());
  await Future<void>.delayed(const Duration(seconds: 3));

  late final String data;

  try {
    data = loadData(event.shouldFail);
  } catch (error) {
    emit(LoadFailureState(error));
    rethrow;
  }

  emit(LoadSuccessState(data));
}

String loadData(bool shouldFail) {
  if (shouldFail) {
    throw Exception('An exception was thrown when trying to load data');
  }

  return 'foo bar 42';
}

abstract class ExampleState {
  const ExampleState(this.description);

  final String description;
}

class InitialState extends ExampleState {
  const InitialState() : super('Initial state');
}

class LoadInProgressState extends ExampleState {
  const LoadInProgressState() : super('Load in progress ...');
}

class LoadSuccessState extends ExampleState {
  const LoadSuccessState(this.data) : super('Loaded data successfully: $data');

  final String data;
}

class LoadFailureState extends ExampleState {
  const LoadFailureState(this.exception)
      : super(
            'Loading failed because of an exception :( - The exception said "$exception"');

  final Object exception;
}

class StaticSuccessWidget extends StatelessWidget {
  const StaticSuccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.check);
  }
}

class AnimatedLoadingWidget extends StatelessWidget {
  const AnimatedLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RepeatingRotationAnimation(
        child: Icon(Icons.hourglass_bottom));
  }
}

class AnimatedFailureWidget extends StatelessWidget {
  const AnimatedFailureWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RepeatingRotationAnimation(child: Icon(Icons.error));
  }
}

class RepeatingRotationAnimation extends StatefulWidget {
  const RepeatingRotationAnimation({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  State<RepeatingRotationAnimation> createState() =>
      _RepeatingRotationAnimationState();
}

class _RepeatingRotationAnimationState extends State<RepeatingRotationAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.child,
    );
  }
}
