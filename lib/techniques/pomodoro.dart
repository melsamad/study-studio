import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:studystudio/branding.dart';

class Pomodoro extends StatefulWidget {
  const Pomodoro({super.key});

  @override
  State<Pomodoro> createState() => _PomodoroState();
}

class _PomodoroState extends State<Pomodoro> {

  Branding br = Branding();
  String chosen = 'AUTOMATIC';

  late int remainingTime;

  late int breakTime;
  late int bigBreakTime;

  PageController controller = PageController(initialPage: 1);
  PageController controller2 = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    remainingTime = 1500; // Initial title comes from the widget.
    breakTime = 300; // Initial title comes from the widget.
    bigBreakTime = 900;
  }

  bool isStarted = false;
  bool isBreakStarted = false;
  bool isBigBreakStarted = false;

  Timer? _timer;
  Timer? _breaktimer;
  Timer? _bigbreaktimer;

  void stopTimer() {
    setState(() {
      isStarted = !isStarted;
    });
    _timer?.cancel();

  }

  // break
  void stopBreakTimer() {
    setState(() {
      isBreakStarted = !isBreakStarted;
    });
    _breaktimer?.cancel();

  }

  // big break
  void stopBigBreakTimer() {
    setState(() {
      isBigBreakStarted = !isBigBreakStarted;
    });
    _bigbreaktimer?.cancel();

  }


   @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    _timer?.cancel(); // Clean up the timer
    _breaktimer?.cancel(); 
    _bigbreaktimer?.cancel();
    
    super.dispose();
  }

  int amountOfReps = 0;

  

  @override
  Widget build(BuildContext context) {

    String formattedTime() {
    final minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

   String formattedBreakTime() {
    final minutes = (breakTime ~/ 60).toString().padLeft(1, '0');
    final seconds = (breakTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

   String formattedBigBreakTime() {
    final minutes = (bigBreakTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (bigBreakTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

   String formattedT = formattedTime();
   String formattedBreakT = formattedBreakTime();
   String formattedBigBreakT = formattedBigBreakTime();


    return Scaffold(
      appBar: AppBar(
        backgroundColor: br.white,
        centerTitle: false,
        toolbarHeight: 100,
        title: ListTile(
            title: Text('POMODORO',
            style: GoogleFonts.viga(
              color: br.black
            ),
            ),
      
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text( 
                chosen == 'AUTOMATIC' ? 
                'This technique uses 25-minute study intervals (pomodoros) with 5-minute breaks in between. After every fourth pomodoro, take a longer break.' : 
                'The custom option will not automatically set the timers for you. Instead, you control the timers by choosing which one you want.',
              style: GoogleFonts.bricolageGrotesque(
                color: Colors.grey[700],
                fontSize: 13
              ),
              ),
            ),
          ),
      
      ),
      // appBar:
      backgroundColor: br.white,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: br.white,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(chosen == 'AUTOMATIC' ? Colors.red : br.white),
                    side: WidgetStatePropertyAll(BorderSide(
                      width: 2,
                      color: Colors.red
                    ))
                  ),
                  onPressed: () {
                    setState(() {
                      chosen = 'AUTOMATIC';
                    });
                  }, 
                  child: Text('AUTOMATIC',
                  style: GoogleFonts.viga(
                    color: chosen == 'AUTOMATIC' ? br.white : Colors.red
                  ),
                  )
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(chosen == 'CUSTOM' ? Colors.red : br.white),
                    side: WidgetStatePropertyAll(BorderSide(
                      width: 2,
                      color: Colors.red
                    ))
                  ),
                  onPressed: () {
                    setState(() {
                      chosen = 'CUSTOM';
                    });
                  }, 
                  child: Text('CUSTOM',
                  style: GoogleFonts.viga(
                    color: chosen == 'CUSTOM' ? br.white : Colors.red
                  ),
                  )
                ),
              ),
            ),


          ],
        ),
      ),
      body:  chosen == 'AUTOMATIC' ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [      
          // ListTile(
          //   title: Text('POMODORO',
          //   style: GoogleFonts.viga(
          //     color: br.black
          //   ),
          //   ),
      
          //   subtitle: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 10.0),
          //     child: Text('This technique uses 25-minute study intervals (pomodoros) with 5-minute breaks in between. After every fourth pomodoro, take a longer break.',
          //     style: GoogleFonts.bricolageGrotesque(
          //       color: Colors.grey[700],
          //       fontSize: 13
          //     ),
          //     ),
          //   ),
          // ),

          SizedBox(
            height: 10,
          ),
      
        
           Expanded(
            
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: controller,
              children: [
          
                // big break
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Stack(
                            alignment: Alignment.center,
                            children: [
                               Center(child: Lottie.asset('lib/animation/tea.json', width: 280, repeat: isBigBreakStarted)),
                              PieChart(
                                
                                PieChartData(
                                sectionsSpace: 0,
                                sections: [
                                  
                                  PieChartSectionData(
                                    value: 900 - bigBreakTime.toDouble(),
                                    radius: 20,
                                    showTitle: false,
                                    color: const Color.fromARGB(255, 209, 209, 209)
                                  ),
                                    
                                  PieChartSectionData(
                                    value: bigBreakTime.toDouble(),
                                    radius: 20,
                                    showTitle: false,
                                    color: bigBreakTime >= bigBreakTime / 2 ? Colors.red :
                                    bigBreakTime < bigBreakTime / 2 && bigBreakTime > bigBreakTime / 4 ?
                                    Colors.red[700] : Colors.red[900]
                                  ),
                                ]
                              )),
                          
                            
                            ],
                          ),
                  ),
                ),
          
          
                // work
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                
                                PieChartData(
                                sectionsSpace: 0,
                                sections: [
                                  
                                  PieChartSectionData(
                                    value: 1500 - remainingTime.toDouble(),
                                    radius: 20,
                                    showTitle: false,
                                    color: const Color.fromARGB(255, 209, 209, 209)
                                  ),
                                    
                                  PieChartSectionData(
                                    value: remainingTime.toDouble(),
                                    radius: 20,
                                    showTitle: false,
                                    color: remainingTime >= remainingTime / 2 ? Colors.red :
                                    remainingTime < remainingTime / 2 && remainingTime > remainingTime / 4 ?
                                    Colors.red[700] : Colors.red[900]
                                  ),
                                ]
                              )),
                          
                             Center(child: Lottie.asset('lib/animation/study.json', width: 300, repeat: isStarted))
                            ],
                          ),
                  ),
                ),
           
                // break
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                
                                PieChartData(
                                sectionsSpace: 0,
                                sections: [
                                  
                                  PieChartSectionData(
                                    value: 300 - breakTime.toDouble(),
                                    radius: 20,
                                    showTitle: false,
                                    color: const Color.fromARGB(255, 209, 209, 209)
                                  ),
                                    
                                  PieChartSectionData(
                                    value: breakTime.toDouble(),
                                    radius: 20,
                                    showTitle: false,
                                    color: breakTime >= breakTime / 2 ? Colors.red :
                                    breakTime < breakTime / 2 && breakTime > breakTime / 4 ?
                                    Colors.red[700] : Colors.red[900]
                                  ),
                                ]
                              )),
                          
                             Center(child: Lottie.asset('lib/animation/break.json', width: 300, repeat: isBreakStarted))
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          
          SizedBox(
            width: double.infinity,
            height: 150,
            child: PageView(
              
            physics: NeverScrollableScrollPhysics(),
            controller: controller2,
            children: [
          
          
              // big break
              Column(
                children: [
                  const SizedBox(
                  height: 20,
                ),
                  
                Text(formattedBigBreakT,
                   style: TextStyle(
                    color: br.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 30
                   ),
                   ),
                  
                !isBigBreakStarted ? 
                
                IconButton(
                  onPressed: () {
                    setState(() {
                    isBigBreakStarted = !isBigBreakStarted;
                    bigBreakTime = 900;
                  });
                  _bigbreaktimer = Timer.periodic(
                    const Duration(seconds: 1), (timer) {
                    if (bigBreakTime > 0) { 
                      setState(() {
                        bigBreakTime--;
                      });
                    } else {
                      _bigbreaktimer?.cancel();         
                       setState(() {
                    isBigBreakStarted = !isBigBreakStarted;
                    });
                    controller.nextPage(
                    duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
                    controller2.nextPage(
                    duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
                    }
            
            
                   
            
            
                  });
                  }, 
                  icon: Icon(Icons.play_arrow, color: br.black, size: 40,)
                ) : 
                
                IconButton(
                  onPressed: stopBigBreakTimer, 
                  icon: Icon(Icons.pause, color: br.black, size: 40,)
                ),
                  
                  
                SizedBox(
                  height: 10,
                ),
                ],
              ),
              
              // work
              Column(
                children: [
                  const SizedBox(
                  height: 20,
                ),
                  
                Text(formattedT,
                   style: TextStyle(
                    color: br.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 30
                   ),
                   ),
                  
                !isStarted ? 
                
                IconButton(
                  onPressed: () {

                    setState(() {
    isStarted = !isStarted;
    remainingTime = 1500; // Reset to 25 minutes
  });

  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (remainingTime > 0) {
      setState(() {
        remainingTime--;
      });
    } else {
      _timer?.cancel();
      setState(() {
        isStarted = !isStarted;
      });

      // Check the number of repetitions and decide which break to use
      if (amountOfReps < 4) {
        // Short Break (5 minutes)
        setState(() {
          isBreakStarted = true;
          breakTime = 300;
        });

        // Start break timer
        _breaktimer = Timer.periodic(Duration(seconds: 1), (breakTimer) {
          if (breakTime > 0) {
            setState(() {
              breakTime--;
            });
          } else {
            _breaktimer?.cancel();
            setState(() {
              isBreakStarted = false;
            });
            // Move to the next page after the break
            controller.nextPage(
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
            );
            controller2.nextPage(
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
            );
            setState(() {
              amountOfReps++;
              remainingTime = 1500; // Reset the work timer
            });
          }
        });
      } else {
        // Long Break (15 minutes)
        setState(() {
          isBigBreakStarted = true;
          bigBreakTime = 900;
        });

        // Start long break timer
        _bigbreaktimer = Timer.periodic(Duration(seconds: 1), (bigBreakTimer) {
          if (bigBreakTime > 0) {
            setState(() {
              bigBreakTime--;
            });
          } else {
            _bigbreaktimer?.cancel();
            setState(() {
              isBigBreakStarted = false;
            });
            // Move to the previous page after the break
            controller.previousPage(
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
            );
            controller2.previousPage(
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
            );
            setState(() {
              amountOfReps = 0; // Reset repetitions for next round
              remainingTime = 1500; // Reset the work timer
            });
          }
        });
      }
    }
  });

  
                  }, 
                  icon: Icon(Icons.play_arrow, color: br.black, size: 40,)
                ) : 
                
                IconButton(
                  onPressed: stopTimer, 
                  icon: Icon(Icons.pause, color: br.black, size: 40,)
                ),
                  
                  
                SizedBox(
                  height: 10,
                ),
                ],
              ),
          
              
              // small break
              Column(
                children: [
                  const SizedBox(
                  height: 20,
                ),
                  
                Text(formattedBreakT,
                   style: TextStyle(
                    color: br.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 30
                   ),
                   ),
                  
                !isBreakStarted ? 
                
                IconButton(
                  onPressed: () {
                    setState(() {
                    isBreakStarted = !isBreakStarted;
                    breakTime = 300;
                  });
                  _breaktimer = Timer.periodic(
                    const Duration(seconds: 1), (timer) {
                    if (breakTime > 0) { 
                      setState(() {
                        breakTime--;
                      });
                    } else {
                      _breaktimer?.cancel();         
                       setState(() {
                    isBreakStarted = !isBreakStarted;
                    });
                    controller.previousPage(
                    duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
                    controller2.previousPage(
                    duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
                    }
            
            
                   
            
            
                  });
                  }, 
                  icon: Icon(Icons.play_arrow, color: br.black, size: 40,)
                ) : 
                
                IconButton(
                  onPressed: stopBreakTimer, 
                  icon: Icon(Icons.pause, color: br.black, size: 40,)
                ),
                  
                  
                
                ],
              )
            ],
            ),
          )

          
        
        
        ],
      ) : CustomPomodoro(),
    );
  }
}



class CustomPomodoro extends StatefulWidget {
  const CustomPomodoro({super.key});

  @override
  State<CustomPomodoro> createState() => _CustomPomodoroState();
}

class _CustomPomodoroState extends State<CustomPomodoro> {

  Branding br = Branding();
  String chosen = 'AUTOMATIC';

  late int remainingTime;

  late int breakTime;
  late int bigBreakTime;

  PageController controller = PageController(initialPage: 1);
  PageController controller2 = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    remainingTime = 1500; // Initial title comes from the widget.
    breakTime = 300; // Initial title comes from the widget.
    bigBreakTime = 900;
  }

  bool isStarted = false;
  bool isBreakStarted = false;
  bool isBigBreakStarted = false;

  Timer? _timer;
  Timer? _breaktimer;
  Timer? _bigbreaktimer;

  void stopTimer() {
    setState(() {
      isStarted = !isStarted;
    });
    _timer?.cancel();

  }

  // break
  void stopBreakTimer() {
    setState(() {
      isBreakStarted = !isBreakStarted;
    });
    _breaktimer?.cancel();

  }

  // big break
  void stopBigBreakTimer() {
    setState(() {
      isBigBreakStarted = !isBigBreakStarted;
    });
    _bigbreaktimer?.cancel();

  }


   @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    _timer?.cancel(); // Clean up the timer
    _breaktimer?.cancel(); 
    _bigbreaktimer?.cancel();
    
    super.dispose();
  }

  int amountOfReps = 0;

  

  @override
  Widget build(BuildContext context) {

    String formattedTime() {
    final minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

   String formattedBreakTime() {
    final minutes = (breakTime ~/ 60).toString().padLeft(1, '0');
    final seconds = (breakTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

   String formattedBigBreakTime() {
    final minutes = (bigBreakTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (bigBreakTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

   String formattedT = formattedTime();
   String formattedBreakT = formattedBreakTime();
   String formattedBigBreakT = formattedBigBreakTime();


    return SizedBox(
      height: double.infinity,
      child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [   

            SizedBox(
              height: 20,
            ), 
          
            Expanded(
              child: PageView(
                
                controller: controller,
                children: [
      
                  // big break
                  Column(
                    children: [
                      Expanded(
                       
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      
                                      PieChartData(
                                      sectionsSpace: 0,
                                      sections: [
                                        
                                        PieChartSectionData(
                                          value: 900 - bigBreakTime.toDouble(),
                                          radius: 20,
                                          showTitle: false,
                                          color: const Color.fromARGB(255, 209, 209, 209)
                                        ),
                                          
                                        PieChartSectionData(
                                          value: bigBreakTime.toDouble(),
                                          radius: 20,
                                          showTitle: false,
                                          color: bigBreakTime >= bigBreakTime / 2 ? Colors.red :
                                          bigBreakTime < bigBreakTime / 2 && bigBreakTime > bigBreakTime / 4 ?
                                          Colors.red[700] : Colors.red[900]
                                        ),
                                      ]
                                    )),
                                
                                   Center(child: Lottie.asset('lib/animation/tea.json', width: 300, repeat: isBigBreakStarted))
                                  ],
                                ),
                        ),
                      ),
                    
                    // big break
                Column(
                  children: [
                    const SizedBox(
                    height: 20,
                  ),
                    
                  Text(formattedBigBreakT,
                     style: TextStyle(
                      color: br.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 30
                     ),
                     ),
                    
                  !isBigBreakStarted ? 
                  
                  IconButton(
                    onPressed: () {
                      setState(() {
                      isBigBreakStarted = !isBigBreakStarted;
                      bigBreakTime = 900;
                    });
                    _bigbreaktimer = Timer.periodic(
                      const Duration(seconds: 1), (timer) {
                      if (bigBreakTime > 0) { 
                        setState(() {
                          bigBreakTime--;
                        });
                      } else {
                        _bigbreaktimer?.cancel();         
                         setState(() {
                      isBigBreakStarted = !isBigBreakStarted;
                      });
                      }               
              
              
                    });
                    }, 
                    icon: Icon(Icons.play_arrow, color: br.black, size: 40,)
                  ) : 
                  
                  IconButton(
                    onPressed: stopBigBreakTimer, 
                    icon: Icon(Icons.pause, color: br.black, size: 40,)
                  ),
                    
                    
                  SizedBox(
                    height: 10,
                  ),
                  ],
                ),
                
                
                    ],
                  ),
      
      
                  // work
                  Column(
                    children: [
                      Expanded(               
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      
                                      PieChartData(
                                      sectionsSpace: 0,
                                      sections: [
                                        
                                        PieChartSectionData(
                                          value: 1500 - remainingTime.toDouble(),
                                          radius: 20,
                                          showTitle: false,
                                          color: const Color.fromARGB(255, 209, 209, 209)
                                        ),
                                          
                                        PieChartSectionData(
                                          value: remainingTime.toDouble(),
                                          radius: 20,
                                          showTitle: false,
                                          color: remainingTime >= remainingTime / 2 ? Colors.red :
                                          remainingTime < remainingTime / 2 && remainingTime > remainingTime / 4 ?
                                          Colors.red[700] : Colors.red[900]
                                        ),
                                      ]
                                    )),
                                
                                   Center(child: Lottie.asset('lib/animation/study.json', width: 300, repeat: isStarted))
                                  ],
                                ),
                        ),
                      ),
                  
                  
                      // work
                                Column(
                  children: [
                    const SizedBox(
                    height: 20,
                  ),
                    
                  Text(formattedT,
                     style: TextStyle(
                      color: br.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 30
                     ),
                     ),
                    
                  !isStarted ? 
                  
                  IconButton(
                    onPressed: () {
                  
                  
                      setState(() {
                      isStarted = !isStarted;
                      remainingTime = 1500;
                    });
                    _timer = Timer.periodic(
                      const Duration(seconds: 1), (timer) {
                      if (remainingTime > 0) { 
                        setState(() {
                        remainingTime--;
                        });
                      } else {
                        _timer?.cancel();         
                         setState(() {
                      isStarted = !isStarted;
                      });
                  
                              
                  
                      }
                              
                      // for the countdown
                      
                              
                              
                              
                    });
                    }, 
                    icon: Icon(Icons.play_arrow, color: br.black, size: 40,)
                  ) : 
                  
                  IconButton(
                    onPressed: stopTimer, 
                    icon: Icon(Icons.pause, color: br.black, size: 40,)
                  ),
                    
                    
                  SizedBox(
                    height: 10,
                  ),
                  ],
                                ),
                    ],
                  ),
       
                  // break
                  Column(
                    children: [
                      Expanded(
                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      
                                      PieChartData(
                                      sectionsSpace: 0,
                                      sections: [
                                        
                                        PieChartSectionData(
                                          value: 300 - breakTime.toDouble(),
                                          radius: 20,
                                          showTitle: false,
                                          color: const Color.fromARGB(255, 209, 209, 209)
                                        ),
                                          
                                        PieChartSectionData(
                                          value: breakTime.toDouble(),
                                          radius: 20,
                                          showTitle: false,
                                          color: breakTime >= breakTime / 2 ? Colors.red :
                                          breakTime < breakTime / 2 && breakTime > breakTime / 4 ?
                                          Colors.red[700] : Colors.red[900]
                                        ),
                                      ]
                                    )),
                                
                                   Center(child: Lottie.asset('lib/animation/break.json', width: 300, repeat: isBreakStarted))
                                  ],
                                ),
                        ),
                      ),
      
                      // small break
                Column(
                  children: [
                    const SizedBox(
                    height: 20,
                  ),
                    
                  Text(formattedBreakT,
                     style: TextStyle(
                      color: br.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 30
                     ),
                     ),
                    
                  !isBreakStarted ? 
                  
                  IconButton(
                    onPressed: () {
                      setState(() {
                      isBreakStarted = !isBreakStarted;
                      breakTime = 300;
                    });
                    _breaktimer = Timer.periodic(
                      const Duration(seconds: 1), (timer) {
                      if (breakTime > 0) { 
                        setState(() {
                          breakTime--;
                        });
                      } else {
                        _breaktimer?.cancel();         
                         setState(() {
                      isBreakStarted = !isBreakStarted;
                      });
                    
                      }
              
              
                     
              
              
                    });
                    }, 
                    icon: Icon(Icons.play_arrow, color: br.black, size: 40,)
                  ) : 
                  
                  IconButton(
                    onPressed: stopBreakTimer, 
                    icon: Icon(Icons.pause, color: br.black, size: 40,)
                  ),
                    
                    
                  
                  ],
                )
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 30,
            ), 
          
      
            
           SmoothPageIndicator(
            effect: ExpandingDotsEffect(
              dotColor: Colors.grey[400]!,
              activeDotColor: Colors.red,
              dotHeight: 10,
              dotWidth: 10
            ),
            controller: controller, 
            count: 3
          ),
          
          ],
        ),
    );
  }
}