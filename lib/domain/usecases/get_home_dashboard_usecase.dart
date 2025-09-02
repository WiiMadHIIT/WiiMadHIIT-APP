import '../../data/repository/home_repository.dart';
import '../entities/home/home_entities.dart';

// 新增：获取公告栏用例
class GetHomeAnnouncementsUseCase {
  final HomeRepository repository;

  GetHomeAnnouncementsUseCase(this.repository);

  Future<List<Announcement>> execute() {
    return repository.getHomeAnnouncements();
  }
}

// 新增：获取最近冠军用例
class GetHomeChampionsUseCase {
  final HomeRepository repository;

  GetHomeChampionsUseCase(this.repository);

  Future<List<Champion>> execute() {
    return repository.getHomeChampions();
  }
}

// 新增：获取活跃用户用例
class GetHomeActiveUsersUseCase {
  final HomeRepository repository;

  GetHomeActiveUsersUseCase(this.repository);

  Future<List<ActiveUser>> execute() {
    return repository.getHomeActiveUsers();
  }
}
