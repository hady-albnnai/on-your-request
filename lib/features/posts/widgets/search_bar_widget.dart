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

        // ── شريط البحث النصي ──────────────────────────────────────────
        SizedBox(
          height: 40,
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
                  color: AppColors.basalt400, size: 18),
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

        // ── فلتر المنطقة (4 أزرار) ───────────────────────────────────
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.wheat400 : AppColors.basalt700,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusSm),
                        border: Border.all(
                          color: selected
                              ? AppColors.wheat400 : AppColors.basalt600),
                      ),
                      child: Center(
                        child: Text(
                          r == AppStrings.allRegions ? 'الكل' : r,
                          style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 11,
                            fontWeight: FontWeight.w700,
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
        const SizedBox(height: AppDimens.sm),

        // ── فلتر الفئة (منسدل) ──────────────────────────────────────
        Consumer<PostsProvider>(
          builder: (context, prov, _) => Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.basalt700,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(
                color: prov.selectedCategory != AppStrings.allCategories
                    ? AppColors.wheat400 : AppColors.basalt600,
                width: prov.selectedCategory != AppStrings.allCategories
                    ? 1.5 : 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: prov.selectedCategory,
                dropdownColor: AppColors.basalt800,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: prov.selectedCategory != AppStrings.allCategories
                      ? AppColors.wheat300 : AppColors.basalt400,
                  size: 20,
                ),
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: AppDimens.fontSm,
                  color: AppColors.wheat300,
                ),
                items: AppStrings.categories.map((c) =>
                  DropdownMenuItem(
                    value: c,
                    child: Text(c,
                      style: TextStyle(
                        fontFamily: 'Cairo', fontSize: AppDimens.fontSm,
                        color: c == AppStrings.allCategories
                            ? AppColors.basalt300 : AppColors.wheat300,
                      )),
                  )).toList(),
                onChanged: (c) { if (c != null) prov.setCategory(c); },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
