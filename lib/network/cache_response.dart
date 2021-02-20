class CachedResponse
{
  int lifetime;
  int created;
  dynamic data;

  CachedResponse(this.lifetime, this.created, this.data);
}