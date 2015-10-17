class String

  # 文字列の重複を取り除いた数
  def uniq_count
    squeeze.split(//).uniq.count
  end
end
