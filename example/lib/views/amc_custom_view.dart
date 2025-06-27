import 'package:flutter/material.dart';

/// AMC Custom View - Movie theater seat selector with popcorn promotion
///
/// This view displays a movie seat selector interface with AMC branding
/// and a popcorn deals banner.
class AMCCustomView extends StatefulWidget {
  final Map<String, dynamic> properties;

  const AMCCustomView({Key? key, required this.properties}) : super(key: key);

  @override
  _AMCCustomViewState createState() => _AMCCustomViewState();
}

class _AMCCustomViewState extends State<AMCCustomView>
    with SingleTickerProviderStateMixin {
  Set<String> selectedSeats = {};
  bool showConfirmation = false;
  static const double seatPrice = 14.50;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleView() {
    if (showConfirmation) {
      _animationController.reverse().then((_) {
        setState(() {
          showConfirmation = false;
        });
        _animationController.forward();
      });
    } else {
      _animationController.reverse().then((_) {
        setState(() {
          showConfirmation = true;
        });
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start the animation when the widget is first built
    if (_animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
    }

    final movieTitle = widget.properties['movie_title'] ?? 'Select Your Seats';
    final showtime = widget.properties['showtime'] ?? '7:00 PM';
    final popcornDeal =
        widget.properties['popcorn_deal'] ?? '50% off Large Popcorn Combo!';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fill available space
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: showConfirmation
                ? _buildConfirmationContent()
                : _buildSeatSelectionContent(movieTitle, showtime, popcornDeal),
          ),
        );
      },
    );
  }

  Widget _buildSeatSelectionContent(
      String movieTitle, String showtime, String popcornDeal) {
    return Column(
      children: [
        // AMC Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFED1C24), // AMC Red
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/amc-logo.png',
                height: 24,
                fit: BoxFit.contain,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(
                    right: 40), // Add padding to avoid close button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      movieTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      showtime,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Seat Selector Area
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: _buildSeatGrid(),
            ),
          ),
        ),

        // Popcorn Deal Banner
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/popcorn.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Offer!',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      popcornDeal,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed:
                        selectedSeats.isNotEmpty ? () => _toggleView() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED1C24),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Continue'),
                  ),
                  TextButton(
                    onPressed: () => _toggleView(),
                    child: Text(
                      'No thanks',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Screen indicator
          Container(
            width: 180,
            height: 4,
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Text(
            'SCREEN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 12),

          // Seat grid with aisles
          ...List.generate(
            4,
            (row) => Padding(
              padding: EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Left section (seats 1-2)
                  ...List.generate(2, (col) => _buildSeat(row, col)),
                  SizedBox(width: 12), // Left aisle

                  // Center section (seats 3-6)
                  ...List.generate(4, (col) => _buildSeat(row, col + 2)),
                  SizedBox(width: 12), // Right aisle

                  // Right section (seats 7-8)
                  ...List.generate(2, (col) => _buildSeat(row, col + 6)),
                ],
              ),
            ),
          ),

          // Legend
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(Colors.grey.shade700, 'Available'),
              SizedBox(width: 16),
              _buildLegendItem(Color(0xFFED1C24), 'Selected'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade600),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSeat(int row, int col) {
    final seatId = '${String.fromCharCode(65 + row)}${col + 1}';
    final isSelected = selectedSeats.contains(seatId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedSeats.remove(seatId);
          } else {
            selectedSeats.add(seatId);
          }
        });
      },
      child: Container(
        width: 28,
        height: 28,
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFED1C24) : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            seatId,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationContent() {
    final total = selectedSeats.length * seatPrice;

    return Column(
      children: [
        // AMC Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFED1C24),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/amc-logo.png',
                height: 24,
                fit: BoxFit.contain,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 40),
                child: Text(
                  'Confirmation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_filter,
                      color: Colors.white,
                      size: 36,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Enjoy Your Movie!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Selected seats
                if (selectedSeats.isNotEmpty) ...[
                  Text(
                    'Selected Seats',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxHeight: 120),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...selectedSeats
                                .map((seat) => Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Seat $seat',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '\$${seatPrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            Divider(color: Colors.grey.shade700, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Color(0xFFED1C24),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'No seats selected',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom action bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.grey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _toggleView(),
                icon: Icon(Icons.arrow_back, color: Colors.white70, size: 16),
                label: Text(
                  'Change Seats',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement confirmation action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFED1C24),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: Text('Confirm'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
