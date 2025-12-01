require 'rails_helper'

RSpec.describe StardustsController, type: :controller do
  describe 'GET #index' do
    context 'when stardusts exist' do
      let!(:stardust1) { Stardust.create!(value: 100, memo: 'First stardust') }
      let!(:stardust2) { Stardust.create!(value: 200, memo: 'Second stardust') }

      it 'returns all stardusts' do
        get :index
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(2)
        expect(json_response['data'].map { |s| s['id'] }).to contain_exactly(stardust1.id, stardust2.id)
      end
    end

    context 'when no stardusts exist' do
      it 'returns empty array' do
        get :index
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to eq([])
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          stardust: {
            value: 150,
            memo: 'Test stardust'
          }
        }
      end

      it 'creates a new stardust' do
        expect {
          post :create, params: valid_params
        }.to change(Stardust, :count).by(1)
      end

      it 'returns the created stardust with status :created' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['value']).to eq(150)
        expect(json_response['data']['memo']).to eq('Test stardust')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          stardust: {
            value: nil,
            memo: 'Invalid stardust'
          }
        }
      end

      it 'does not create a new stardust' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Stardust, :count)
      end

      it 'returns error messages with status :unprocessable_entity' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_present
      end
    end

    context 'without stardust parameter' do
      it 'raises an error' do
        expect {
          post :create, params: {}
        }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe 'GET #show' do
    context 'when stardust exists' do
      let!(:stardust) { Stardust.create!(value: 300, memo: 'Show test stardust') }

      it 'returns the stardust' do
        get :show, params: { id: stardust.id }
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id']).to eq(stardust.id)
        expect(json_response['data']['value']).to eq(300)
        expect(json_response['data']['memo']).to eq('Show test stardust')
      end
    end

    context 'when stardust does not exist' do
      it 'returns not found error' do
        get :show, params: { id: 99999 }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Stardust not found')
      end
    end
  end

  describe 'PUT #update' do
    let!(:stardust) { Stardust.create!(value: 400, memo: 'Original memo') }

    context 'with valid parameters' do
      let(:update_params) do
        {
          id: stardust.id,
          stardust: {
            value: 500,
            memo: 'Updated memo'
          }
        }
      end

      it 'updates the stardust' do
        put :update, params: update_params
        stardust.reload
        expect(stardust.value).to eq(500)
        expect(stardust.memo).to eq('Updated memo')
      end

      it 'returns the updated stardust' do
        put :update, params: update_params
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['value']).to eq(500)
        expect(json_response['data']['memo']).to eq('Updated memo')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_update_params) do
        {
          id: stardust.id,
          stardust: {
            value: nil,
            memo: 'Invalid update'
          }
        }
      end

      it 'does not update the stardust' do
        original_value = stardust.value
        put :update, params: invalid_update_params
        stardust.reload
        expect(stardust.value).to eq(original_value)
      end

      it 'returns error messages with status :unprocessable_entity' do
        put :update, params: invalid_update_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_present
      end
    end

    context 'when stardust does not exist' do
      it 'returns not found error' do
        put :update, params: { id: 99999, stardust: { value: 100 } }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Stardust not found')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when stardust exists' do
      let!(:stardust) { Stardust.create!(value: 600, memo: 'To be deleted') }

      it 'deletes the stardust' do
        expect {
          delete :destroy, params: { id: stardust.id }
        }.to change(Stardust, :count).by(-1)
      end

      it 'returns success message' do
        delete :destroy, params: { id: stardust.id }
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Stardust deleted successfully')
      end
    end

    context 'when stardust does not exist' do
      it 'returns not found error' do
        delete :destroy, params: { id: 99999 }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Stardust not found')
      end
    end
  end
end

