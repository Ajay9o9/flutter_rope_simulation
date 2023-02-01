// https://github.com/Ajay9o9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rope_simulation/rope_painter.dart';
import 'package:vector_math/vector_math_64.dart' as v;

import 'particle.dart';
import 'spring.dart';

class RopeSimulationWidget extends StatefulWidget {
  const RopeSimulationWidget({Key? key}) : super(key: key);

  @override
  State<RopeSimulationWidget> createState() => _StringSimulationWidgetState();
}

class _StringSimulationWidgetState extends State<RopeSimulationWidget> {
  late v.Vector2 gravity;

  late List<Particle> particles;
  late List<Spring> springs;
  double spacing = 20;
  double k = 0.5;
  late Timer timer;
  late int noOfParticles;

  @override
  void initState() {
    //setting gravity to 0.1
    gravity = v.Vector2(0, 0.1);
    noOfParticles = 10;
    setUpParticlesAndSpring();
    super.initState();
    update();
  }

  //setting up the particles and springs
  void setUpParticlesAndSpring() {
    particles = List<Particle>.filled(noOfParticles, Particle(0, 0));
    springs = List<Spring>.filled(
      noOfParticles,
      Spring(0, 0, particles[0], particles[0]),
    );

    for (int i = 0; i < noOfParticles; i++) {
      particles[i] = Particle(60.0 + i * spacing, 400 + i * spacing);
      if (i != 0) {
        var a = particles[i];
        var b = particles[i - 1];
        var spring = Spring(k, spacing, a, b);
        springs[i] = spring;
      }
    }

    particles[0].locked = true;
    particles.last.locked = true;
  }

  update() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      for (var spring in springs) {
        spring.update();
      }

      for (var particle in particles) {
        particle.applyForce(gravity);
        particle.update();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              Offset tapPosition = details.localPosition;
              var bob = particles[particles.length - 1];
              bob.updatePosition(tapPosition.dx, tapPosition.dy);
              bob.updateVelocity(0, 0);
            },
            child: CustomPaint(
              painter: RopeSimulationPainter(particles, springs),
              child: Container(),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              children: [
                //a slider for changing gravity
                Text("Gravity: ${gravity.y.toStringAsFixed(2)}"),
                Slider(
                  value: gravity.y,
                  min: 0.02,
                  max: 0.99,
                  onChanged: (value) {
                    setState(() {
                      gravity.y = value;
                    });
                  },
                ),
                //a slider for changing spring constant
                Text("Spring Constant: ${k.toStringAsFixed(2)}"),
                Slider(
                  value: k,
                  min: 0.1,
                  max: 0.99,
                  onChanged: (value) {
                    setState(() {
                      k = value;
                      for (var spring in springs) {
                        spring.k = k;
                      }
                    });
                  },
                ),
                //a slider for changing spacing
                Text("Spacing: ${spacing.toStringAsFixed(2)}"),
                Slider(
                  value: spacing,
                  min: 10,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      spacing = value;
                      for (var spring in springs) {
                        spring.restLength = spacing;
                      }
                    });
                  },
                ),
                //a slider for changing number of particles
                Text(
                    "Number of Particles: ${noOfParticles.toStringAsFixed(0)}"),

                Slider(
                  value: noOfParticles.toDouble(),
                  min: 2,
                  max: 20,
                  onChanged: (value) {
                    setState(() {
                      noOfParticles = value.toInt();
                      setUpParticlesAndSpring();
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
