module Private
  class SensitiveWordsController < BaseController
    before_action :get_sensitive_word, only: [:edit, :update, :destroy]
    before_action :current_login
    def index #列表
      @sensitive_words = SensitiveWord.all.order("created_at desc").page(params[:page]).per(200)
    end

    def new
      @sensitive_word = SensitiveWord.new
    end

    def create
      @sensitive_word = SensitiveWord.new(sensitive_word_params)
      begin
        @sensitive_word.save!
      rescue Exception=> e
      end
      redirect_to sensitive_words_path, notice: 'successfully created.'
    end

    def edit
      
    end

    def update
      if @sensitive_word.update(sensitive_word_params)
        redirect_to sensitive_words_path, notice: '更新成功.'
      else
        render :edit
      end
    end

    def destroy
      @sensitive_word.destroy
      redirect_to sensitive_words_path, notice: '删除成功'
    end

    private

      def get_sensitive_word
        @sensitive_word = SensitiveWord.find(params[:id])
      end

      def sensitive_word_params
        params.require(:sensitive_word).permit(:name, :is_able)
      end
  end
end
