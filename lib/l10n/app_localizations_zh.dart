// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '儿童中文识字游戏';

  @override
  String get deckList_title => '我的词卡';

  @override
  String get deckList_addDeck => '添加词库';

  @override
  String get deckList_addGroup => '添加分组';

  @override
  String get deckList_goToGames => '进入游戏';

  @override
  String get deckList_noDecks => '暂无词库，立即创建';

  @override
  String deckList_cards(int count) {
    return '$count 张卡片';
  }

  @override
  String get deckList_dropToUngroup => '拖至此处以取消分组';

  @override
  String get dialog_deckName => '词库名称？';

  @override
  String get dialog_groupName => '分组名称？';

  @override
  String get dialog_newName => '新名称？';

  @override
  String get dialog_cancel => '取消';

  @override
  String get dialog_ok => '确定';

  @override
  String get dialog_delete => '删除';

  @override
  String get dialog_rename => '重命名';

  @override
  String get dialog_replace => '替换';

  @override
  String get dialog_skip => '跳过';

  @override
  String get deleteGroup_title => '删除分组？';

  @override
  String deleteGroup_message(String name) {
    return '确定删除 \"$name\" 吗？该分组内的词库将变为未分组状态。';
  }

  @override
  String get deleteDeck_title => '删除词库？';

  @override
  String deleteDeck_message(String name) {
    return '确定要删除 \"$name\" 吗？';
  }

  @override
  String get tooltip_rename => '重命名';

  @override
  String get tooltip_delete => '删除';

  @override
  String get export_title => '导出词库';

  @override
  String get export_selectAll => '全选';

  @override
  String get export_button => '导出';

  @override
  String export_success(int count) {
    return '已导出 $count 个词库';
  }

  @override
  String get import_title => '导入收藏';

  @override
  String import_failed(String error) {
    return '导入失败：$error';
  }

  @override
  String get import_processing => '处理中...';

  @override
  String get conflict_title => '词库名称重复';

  @override
  String conflict_messageGrouped(String name, String group) {
    return '在 \"$group\" 分组中已存在名为 \"$name\" 的词库。';
  }

  @override
  String conflict_messageUngrouped(String name) {
    return '已存在名为 \"$name\" 的未分组词库。';
  }

  @override
  String get conflict_whatToDo => '请选择操作：';

  @override
  String get conflict_applyToAll => '对全部剩余冲突应用此操作';

  @override
  String importResult_imported(int count) {
    return '已导入 $count 个';
  }

  @override
  String importResult_replaced(int count) {
    return '已替换 $count 个';
  }

  @override
  String importResult_renamed(int count) {
    return '已重命名 $count 个';
  }

  @override
  String importResult_skipped(int count) {
    return '已跳过 $count 个';
  }

  @override
  String importResult_groupsMerged(int count) {
    return '已合并 $count 个分组';
  }

  @override
  String get importResult_noChanges => '无任何更改';

  @override
  String importResult_complete(String details) {
    return '导入完成：$details';
  }

  @override
  String get gameSelection_title => '游戏';

  @override
  String get gameSelection_selectMode => '选择游戏模式';

  @override
  String gameSelection_playing(String name) {
    return '当前词库：$name';
  }

  @override
  String get game_recallFront_title => '认读模式：只看正面';

  @override
  String get game_recallFront_desc =>
      '逐张卡片练习。认识请点“认识”，不熟请点“再试”。标记“再试”的卡片会反复出现，直到掌握。';

  @override
  String get game_recallBoth_title => '认读模式：正反结合';

  @override
  String get game_recallBoth_desc => '先看正面，点击翻转查看背面答案。适合自测词汇，确认答案后再评分。';

  @override
  String get game_randomMulti_title => '随机模式：多词库（只看正面）';

  @override
  String get game_randomMulti_desc =>
      '组合多个词库同时练习。从每个选中词库随机抽取一张卡片同时展示。适合跨主题快速复习。';

  @override
  String get game_reverseRecall_title => '反向认读';

  @override
  String get game_reverseRecall_desc => '先显示背面文字，点击翻转查看正面。测试反向联想，例如看释义回忆词语。';

  @override
  String get game_multipleChoice_title => '选择题测验';

  @override
  String get game_multipleChoice_desc =>
      '看正面，从4个选项中选出正确的背面。错误答案来自词库中的其他卡片。系统会记录得分。';

  @override
  String get game_memoryMatch_title => '记忆配对';

  @override
  String get game_memoryMatch_desc =>
      '经典记忆游戏：每次翻转两张卡片，匹配正面与背面对应的卡片。记录完成游戏所需步数。';

  @override
  String get game_noBackText => '这个词库的卡片都没有背面文字';

  @override
  String get chooseDeck_title => '选择词库';

  @override
  String get selectDecks_title => '选择词库';

  @override
  String get repeatWords_title => '重复练习？';

  @override
  String get repeatWords_no => '不重复';

  @override
  String get repeatWords_yes => '重复练习';

  @override
  String deckEditor_edit(String name) {
    return '编辑：$name';
  }

  @override
  String get deckEditor_noGroup => '未分组';

  @override
  String get deckEditor_selectGroup => '选择分组';

  @override
  String get deckEditor_addFirst => '添加第一张卡片！';

  @override
  String get deckEditor_front => '正面';

  @override
  String get deckEditor_back => '背面（可选）';

  @override
  String get deckEditor_addCard => '添加卡片';

  @override
  String get deckEditor_editCard => '编辑卡片';

  @override
  String get deckEditor_save => '保存';

  @override
  String game_cardsLeft(int remaining, int total) {
    return '剩余卡片：$remaining / $total';
  }

  @override
  String get game_congratulations => '恭喜你！所有卡片都掌握啦！';

  @override
  String get game_again => '再试';

  @override
  String get game_good => '认识';

  @override
  String get game_finish => '完成';

  @override
  String get game_tapToFlip => '点击翻转';

  @override
  String get game_tapToReveal => '点击显示答案';

  @override
  String get game_allDone => '全部完成！';

  @override
  String get game_next => '下一张';

  @override
  String game_multiDeck(int count) {
    return '多词库（$count）';
  }

  @override
  String get quiz_complete => '测验完成！';

  @override
  String quiz_correct(int correct, int total) {
    return '答对 $correct / $total 题';
  }

  @override
  String quiz_question(int current, int total) {
    return '第 $current / $total 题';
  }

  @override
  String get quiz_selectAnswer => '选择正确答案：';

  @override
  String get quiz_seeResults => '查看结果';

  @override
  String get memory_youWin => '太棒了！';

  @override
  String get memory_moves => '步数';

  @override
  String get memory_matches => '配对';

  @override
  String memory_completedMoves(int count) {
    return '用了 $count 步完成';
  }

  @override
  String get common_again => '再试';

  @override
  String get common_good => '认识';

  @override
  String get common_finish => '完成';

  @override
  String get common_next => '下一张';

  @override
  String get common_congratulations => '恭喜你！所有卡片都掌握啦！';

  @override
  String get common_tapToFlip => '点击翻转';

  @override
  String get common_tapToReveal => '点击显示答案';

  @override
  String get common_allDone => '全部完成！';

  @override
  String get common_noBackText => '这个词库的卡片都没有背面文字';

  @override
  String editor_title(String name) {
    return '编辑：$name';
  }

  @override
  String get editor_noGroup => '未分组';

  @override
  String get editor_addFirstCard => '添加第一张卡片！';

  @override
  String get editor_front => '正面';

  @override
  String get editor_back => '背面（可选）';

  @override
  String get editor_addCard => '添加卡片';

  @override
  String get editor_editCard => '编辑卡片';

  @override
  String get editor_save => '保存';

  @override
  String get editor_selectGroup => '选择分组';

  @override
  String get lang_english => 'EN';

  @override
  String get lang_chinese => '中文';

  @override
  String get themes_title => '主题';

  @override
  String get theme_playful => '活泼主题';

  @override
  String get theme_modest => '简约主题';

  @override
  String get theme_modern => '现代主题';
}
