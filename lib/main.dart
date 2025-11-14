import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime News',
      theme: ThemeData.dark(),
      home: MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng _center = LatLng(41.3851, 2.1734); // Barcelona coordinates
  Set<Marker> _markers = {};
  VideoPlayerController? _videoController;
  bool _isVideoVisible = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    // Add sample markers with associated video URLs
    _markers.addAll([
      Marker(
        markerId: MarkerId('1'),
        position: LatLng(41.3809, 2.1228),
        onTap: () => _onMarkerTapped('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
      ),
      Marker(
        markerId: MarkerId('2'),
        position: LatLng(41.3825, 2.1739),
        onTap: () => _onMarkerTapped('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
      ),
    ]);
  }

  void _onMarkerTapped(String videoUrl) {
    setState(() {
      _isVideoVisible = true;
      _isFullScreen = false;
    });
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
      });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoVisible || _videoController == null || !_videoController!.value.isInitialized) {
      return SizedBox.shrink();
    }
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _isFullScreen ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 2,
      child: Stack(
        children: [
          VideoPlayer(_videoController!),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
              onPressed: _toggleFullScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 60,
      child: Container(
        color: Colors.black54,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text('Timeline (Zoom & Scroll demo)', style: TextStyle(color: Colors.white)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_upward, color: Colors.white),
              onPressed: () {
                // Placeholder for open recording panel
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recording panel (placeholder)')));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
          ),
          _buildVideoPlayer(),
          _buildTimeline(),
        ],
      ),
    );
  }
}
