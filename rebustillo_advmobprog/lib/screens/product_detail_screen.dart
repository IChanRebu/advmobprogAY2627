import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/custom_text.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-bleed image with Hero animation
          Positioned.fill(
            child: Hero(
              tag: 'product_image_${product.id}',
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(color: Colors.grey),
              ),
            ),
          ),

          // subtle gradient to improve contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, const Color.fromRGBO(0,0,0,0.55)],
                ),
              ),
            ),
          ),

          // Bottom rounded sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // small pill handle
                    Center(
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CustomText(
                      text: product.title,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: product.description,
                              fontSize: 13,
                              color: Colors.black87,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              maxLines: _isDescriptionExpanded ? null : 3,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                CustomText(
                                  text: '${product.rating} ★',
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 12),
                                CustomText(
                                  text: '${product.stock} in stock',
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Read all pill button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        ),
                        onPressed: () {
                          setState(() => _isDescriptionExpanded = !_isDescriptionExpanded);
                        },
                        child: Text(_isDescriptionExpanded ? 'Show less' : 'Read all'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // removed unused _detailCard helper to avoid analyzer warning
}
