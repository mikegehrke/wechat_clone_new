import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;

  const ProductImageCarousel({
    super.key,
    required this.images,
    this.height = 400,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemCount: widget.images.length,
          itemBuilder: (context, index, realIndex) {
            final imageUrl = widget.images[index];
            return GestureDetector(
                  onTap: () => _showFullScreenImage(context),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                );
          },
        ),
        
        // Image counter
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        // Navigation arrows for multiple images
        if (widget.images.length > 1) ...[
          Positioned(
            left: 16,
            top: widget.height / 2 - 20,
            child: _buildNavigationButton(
              Icons.chevron_left,
              () => _carouselController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.linear),
              enabled: _currentIndex > 0,
            ),
          ),
          Positioned(
            right: 16,
            top: widget.height / 2 - 20,
            child: _buildNavigationButton(
              Icons.chevron_right,
              () => _carouselController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear),
              enabled: _currentIndex < widget.images.length - 1,
            ),
          ),
        ],
        
        // Dot indicators
        if (widget.images.length > 1)
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButton(IconData icon, VoidCallback onPressed, {bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                initialPage: _currentIndex,
                enableInfiniteScroll: false,
              ),
              items: widget.images.map((imageUrl) {
                return InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
