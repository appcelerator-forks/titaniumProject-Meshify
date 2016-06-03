args = arguments[0] or {}
Ti.API.info args

if args.fromMapView
  $.listSection.setHeaderTitle args.headerTitle
else
  $.listSection.setHeaderView args.headerView