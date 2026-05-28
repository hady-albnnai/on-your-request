import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../posts/providers/posts_provider.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PostsProvider>();
    return Container(
      color: AppColors.basalt800,
      padding: const EdgeInsets.fromLTRB(
          AppDimens.lg, AppDimens.sm, AppDimens.lg, AppDimens.md),
      child: Column(children: [
        // ── حقل البحث ────────────────────────────────────────────────
        SizedBox(
          height: 42,
          child: TextField(
            onChanged: provider.onSearchChanged,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Cairo',
                fontSize: AppDimens.fontSm, color: AppColors.basalt900),
            decoration: InputDecoration(
              hintText:  AppStrings.searchHint,
              hintStyle: const TextStyle(color: AppColors.basalt400,
                  fontFamily: 'Cairo', fontSize: AppDimens.fontSm),
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.basalt400, size: 20),
              filled:     true,
              fillColor:  AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.sm, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sm),

        // ── فلتر المنطقة (3 أزرار + جميع المناطق) ───────────────────
        Consumer<PostsProvider>(
          builder: (context, prov, _) => Row(
            children: AppStrings.regions.map((r) {
              final selected = prov.selectedRegion == r;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => prov.setRegion(r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.wheat400
                            : AppColors.basalt700,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusSm),
                        border: Border.all(
                          color: selected
                              ? AppColors.wheat400
                              : AppColors.basalt600),
                      ),
                      child: Center(
                        child: Text(
                          r == AppStrings.allRegions ? 'الكل' : r,
                          style: TextStyle(
                            fontFamily:  'Cairo',
                            fontSize:    AppDimens.fontXs,
                            fontWeight:  FontWeight.w700,
                            color: selected
                                ? AppColors.basalt900
                                : AppColors.basalt300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}
